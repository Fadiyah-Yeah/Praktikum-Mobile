import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String username = '';

  void _loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading(true);
    errorMessage = null;
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      await loadProfile();
    } on AuthException catch (e) {
      errorMessage = e.message;
      rethrow;
    } finally {
      _loading(false);
    }
  }

  Future<void> register(String username, String email, String password) async {
    _loading(true);
    errorMessage = null;
    try {
      final result = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'username': username.trim()},
      );
      if (result.session != null && result.user != null) {
        await SupabaseService.client.from('profiles').upsert({
          'id': result.user!.id,
          'username': username.trim(),
        });
        this.username = username.trim();
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
      rethrow;
    } finally {
      _loading(false);
    }
  }

  Future<void> loadProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      username = '';
      notifyListeners();
      return;
    }
    final row = await SupabaseService.client
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) {
      username = user.userMetadata?['username'] ?? 'User';
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'username': username,
      });
    } else {
      username = row['username'] ?? 'User';
    }
    notifyListeners();
  }

  Future<void> updateUsername(String value) async {
    final user = SupabaseService.currentUser;
    if (user == null) throw Exception('Silakan login kembali.');
    _loading(true);
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'username': value.trim(),
      });
      username = value.trim();
      notifyListeners();
    } finally {
      _loading(false);
    }
  }

  Future<void> updatePassword(String password) async {
    _loading(true);
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: password),
      );
    } on AuthException catch (e) {
      errorMessage = e.message;
      rethrow;
    } finally {
      _loading(false);
    }
  }

  Future<void> logout() async {
    _loading(true);
    try {
      await SupabaseService.client.auth.signOut();
      username = '';
    } finally {
      _loading(false);
    }
  }
}
