import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  Future<String?> register(User user) async {
    setLoading(true);
    List<User> users = await Storage.getUsers();

    if (users.any((u) => u.username == user.username)) {
      setLoading(false);
      return 'Username already exists';
    }

    await Storage.saveUser(user);
    setLoading(false);
    return null;
  }

  Future<String?> login(String username, String password) async {
  setLoading(true);
  List<User> users = await Storage.getUsers();
  
  User? user;
  try {
    user = users.firstWhere(
        (u) => u.username == username && u.password == password);
  } catch (e) {
    user = null; // user not found
  }

  if (user == null) {
    setLoading(false);
    return 'Invalid username or password';
  }

  await Storage.saveUser(user); // remember session
  setLoading(false);
  return null;
}

  Future<void> logout() async {
    await Storage.clearCurrentUser();
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    return await Storage.getCurrentUser();
  }
}
