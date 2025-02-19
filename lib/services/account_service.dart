import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccountService {
  static const String _userKey = 'registered_users';

  // Sign up a new user
  Future<bool> signUp({
    required String username, 
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Retrieve existing users
      final usersJson = prefs.getString(_userKey) ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      // Check if username already exists
      if (users.any((user) => user['username'] == username)) {
        return false; // Username already taken
      }

      // Create new user
      final newUser = {
        'username': username,
        'password': _hashPassword(password),
      };

      // Add new user to the list
      users.add(newUser);

      // Save updated users list
      await prefs.setString(_userKey, json.encode(users));
      print("created account");
      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String username, 
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Retrieve existing users
      final usersJson = prefs.getString(_userKey) ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      // Find user and verify password
      final user = users.firstWhere(
        (user) => user['username'] == username,
        orElse: () => null,
      );

      if (user == null) {
        return false; // User not found
      }

      // Verify password
      if (user['password'] == _hashPassword(password)) {
        await prefs.setString('current_user', username);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Simple password hashing (Note: In production, use a more secure hashing method)
  String _hashPassword(String password) {
    // This is a very basic hash. In a real app, use a secure hashing library
    return base64Encode(utf8.encode(password));
  }

  // Get current logged-in user
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }

  // Logout user
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('current_user');
  }
}