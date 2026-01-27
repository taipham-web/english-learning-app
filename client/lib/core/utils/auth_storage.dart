import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class AuthStorage {
  static const String _keyUser = 'logged_in_user';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Lưu thông tin user khi đăng nhập thành công
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Lấy thông tin user đã lưu
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        return UserModel.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Kiểm tra đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Xóa thông tin đăng nhập (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Cập nhật thông tin user
  static Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }
}
