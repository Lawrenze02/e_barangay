import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/user_model.dart';


class AuthService with ChangeNotifier {
  User? _currentUser;
  final DBHelper _dbHelper = DBHelper();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<bool> login(String username, String password) async {
    User? user = await _dbHelper.getUser(username, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String username, String password) async {
    try {
      User newUser = User(
        name: name, 
        username: username, 
        password: password, 
        role: 'resident' // Default role
      );
      await _dbHelper.insertUser(newUser);
      // Auto login after register
      return await login(username, password);
    } catch (e) {
      print("Registration Error: $e");
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
