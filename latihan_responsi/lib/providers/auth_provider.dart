
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn =>
      SupabaseService.currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final authUser = SupabaseService.currentUser;

    if (authUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
        _user = UserModel.fromJson(response);
      } else {
        final profile = {
          'id': authUser.id,
          'username': authUser.userMetadata?['name'] ?? 'User',
        };

        await SupabaseService.client
            .from('profiles')
            .upsert(profile);

        _user = UserModel.fromJson(profile);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      await loadProfile();
    } catch (e) {
      _errorMessage = e is AuthException
          ? e.message
          : 'Terjadi kesalahan saat login.';

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response =
          await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': username.trim(),
        },
      );

      if (response.session != null && response.user != null) {
        await SupabaseService.client
            .from('profiles')
            .upsert({
          'id': response.user!.id,
          'username': username.trim(),
        });

        await loadProfile();
      }

      return response.session != null;
    } catch (e) {
      _errorMessage = e is AuthException
          ? e.message
          : 'Terjadi kesalahan saat registrasi.';

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? avatar,
  }) async {
    final authUser = SupabaseService.currentUser;

    if (authUser == null) {
      throw Exception('Pengguna belum login.');
    }

    _setLoading(true);

    try {
      final updates = <String, dynamic>{};

      if (username != null) {
        updates['username'] = username.trim();
      }

      if (avatar != null) {
        updates['avatar'] = avatar;
      }

      if (updates.isNotEmpty) {
        await SupabaseService.client
            .from('profiles')
            .update(updates)
            .eq('id', authUser.id);
      }

      await loadProfile();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await SupabaseService.client.auth.signOut();
      _user = null;
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }
}
