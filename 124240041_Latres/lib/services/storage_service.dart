
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String _avatarKey = 'selected_avatar';
  static const String _onboardingKey = 'onboarding_completed';

  static Future<void> saveAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_avatarKey, avatar);
  }

  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_avatarKey);
  }

  static Future<void> removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_avatarKey);
  }

  static Future<void> saveOnboardingStatus(
    bool completed,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_onboardingKey, completed);
  }

  static Future<bool> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_onboardingKey) ?? false;
  }
}
