import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // Save user data to local storage
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, user.token);
    ApiService.setAuthToken(user.token);
  }

  // Get saved user from local storage
  static Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);
      
      if (userData != null && token != null) {
        final userJson = jsonDecode(userData);
        userJson['token'] = token;
        final user = User.fromJson(userJson);
        ApiService.setAuthToken(token);
        return user;
      }
    } catch (e) {
      print('Error getting saved user: $e');
    }
    return null;
  }

  // Clear user data (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    ApiService.clearAuthToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }
}
