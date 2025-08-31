import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class Storage {
  static const String usersKey = 'users';
  static const String currentUserKey = 'current_user';

  // Save user locally
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList(usersKey) ?? [];
    users.add(jsonEncode(user.toMap()));
    await prefs.setStringList(usersKey, users);
    await prefs.setString(currentUserKey, user.username);
  }

  // Get all users
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList(usersKey) ?? [];
    return users.map((u) => User.fromMap(jsonDecode(u))).toList();
  }

  // Get current logged in user
  static Future<User?> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString(currentUserKey);
  if (username == null) return null;

  List<User> users = await getUsers();
  try {
    return users.firstWhere((u) => u.username == username);
  } catch (e) {
    return null; // no user found
  }
}

  // Logout
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
  }
}
