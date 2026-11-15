import 'package:flutter/foundation.dart';
import '../models/local_user.dart';
import '../services/database_service.dart';
import '../services/password_service.dart';

class AuthProvider extends ChangeNotifier {
  LocalUser? currentUser;
  bool isLoading = false;
  String? errorMessage;

  void _loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> register({
    required String username, required String email, required String password,
  }) async {
    _loading(true);
    try {
      if (await DatabaseService.instance.userByEmail(email.trim()) != null) {
        throw Exception('Email sudah terdaftar.');
      }
      final salt = PasswordService.salt();
      final id = await DatabaseService.instance.register({
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'password_salt': salt,
        'password_hash': PasswordService.hash(password, salt),
      });
      currentUser = LocalUser(id: id, username: username.trim(), email: email.trim().toLowerCase());
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _loading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _loading(true);
    try {
      final row = await DatabaseService.instance.userByEmail(email.trim());
      if (row == null) throw Exception('Email atau password salah.');
      final salt = row['password_salt'] as String;
      final hash = PasswordService.hash(password, salt);
      if (hash != row['password_hash']) throw Exception('Email atau password salah.');
      currentUser = LocalUser.fromMap(row);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _loading(false);
    }
  }

  Future<void> updateUsername(String value) async {
    final user = currentUser;
    if (user == null) throw Exception('Silakan login kembali.');
    _loading(true);
    try {
      await DatabaseService.instance.updateUser(user.id, {'username': value.trim()});
      currentUser = LocalUser(id: user.id, username: value.trim(), email: user.email);
      notifyListeners();
    } finally {
      _loading(false);
    }
  }

  Future<void> updatePassword(String password) async {
    final user = currentUser;
    if (user == null) throw Exception('Silakan login kembali.');
    _loading(true);
    try {
      final salt = PasswordService.salt();
      await DatabaseService.instance.updateUser(user.id, {
        'password_salt': salt,
        'password_hash': PasswordService.hash(password, salt),
      });
    } finally {
      _loading(false);
    }
  }

  Future<void> logout() async {
    currentUser = null;
    notifyListeners();
  }
}
