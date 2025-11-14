import 'dart:convert';
import 'package:mobile/domain/models/user/user_model.dart';
import 'package:mobile/ports/auth/driven/for_storing_auth_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceAuthDataStorage implements ForStoringAuthData {
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _userKey = 'user';

  @override
  Future<void> storeUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> storeIsAuthenticated(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isAuthenticatedKey, isAuthenticated);
  }
  
  @override
  Future<bool> getStoredIsAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  @override
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_isAuthenticatedKey);
    prefs.remove(_userKey);
  }

}