
import 'package:flutter/foundation.dart';
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

  bool get isLoggedIn => SupabaseService.currentUser != null;

  // Mengatur status loading dan memperbarui tampilan.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Mengambil data profil pengguna dari Supabase.
  Future<void> loadProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final currentUser = SupabaseService.currentUser;

      if (currentUser == null) {
        _user = null;
        return;
      }

      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (response != null) {
        _user = UserModel.fromJson(response);
      } else {
        final profileData = {
          'id': currentUser.id,
          'username':
              currentUser.userMetadata?['username'] ?? 'Pengguna',
          'avatar': null,
        };

        final inserted = await SupabaseService.client
            .from('profiles')
            .insert(profileData)
            .select()
            .single();

        _user = UserModel.fromJson(inserted);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Melakukan login menggunakan email dan password.
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

      await _loadProfileWithoutLoading();
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Login gagal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mendaftarkan akun baru dan menyimpan profil pengguna.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username.trim(),
        },
      );

      final newUser = response.user;

      if (newUser != null && response.session != null) {
        final profileData = {
          'id': newUser.id,
          'username': username.trim(),
          'avatar': null,
        };

        final inserted = await SupabaseService.client
            .from('profiles')
            .upsert(profileData)
            .select()
            .single();

        _user = UserModel.fromJson(inserted);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Registrasi gagal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mengambil profil tanpa mengubah status loading utama.
  Future<void> _loadProfileWithoutLoading() async {
    final currentUser = SupabaseService.currentUser;

    if (currentUser == null) {
      _user = null;
      return;
    }

    final response = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    if (response != null) {
      _user = UserModel.fromJson(response);
    } else {
      final inserted = await SupabaseService.client
          .from('profiles')
          .insert({
            'id': currentUser.id,
            'username':
                currentUser.userMetadata?['username'] ?? 'Pengguna',
            'avatar': null,
          })
          .select()
          .single();

      _user = UserModel.fromJson(inserted);
    }
  }

  // Memperbarui username dan avatar pengguna.
  Future<void> updateProfile({
    String? username,
    String? avatar,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final currentUser = SupabaseService.currentUser;

      if (currentUser == null) {
        throw Exception('Pengguna belum login.');
      }

      final updateData = <String, dynamic>{};

      if (username != null) {
        updateData['username'] = username.trim();
      }

      if (avatar != null) {
        updateData['avatar'] = avatar;
      }

      if (updateData.isEmpty) return;

      final response = await SupabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', currentUser.id)
          .select()
          .single();

      _user = UserModel.fromJson(response);
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Memperbarui password akun melalui Supabase Auth.
  Future<void> updatePassword(String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (SupabaseService.currentUser == null) {
        throw Exception('Pengguna belum login.');
      }

      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui password: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mengakhiri sesi login dan menghapus data profil lokal.
  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await SupabaseService.client.auth.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = 'Logout gagal: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
