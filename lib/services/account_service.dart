import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccountService {
  static const String _userKey = 'registered_users';
  static const String _adminUsername = 'admin'; // Default admin username
  static const String _adminPassword = 'admin123'; // Default admin password
  static const String _defaultAdminUsername = 'admin';
  static const String _defaultAdminPassword = 'admin123';

  // Sign up a new user
  Future<bool> signUp({
    required String username, 
    required String password,
    String role = 'user', // Default role is user
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
        'role': role,
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
  Future<Map<String, dynamic>?> login({
    required String username, 
    required String password,
  }) async {
    try {
      // Check for admin login first
      if (username == _adminUsername && _hashPassword(password) == _hashPassword(_adminPassword)) {
        await _saveCurrentUser(username, 'admin');
        return {'username': username, 'role': 'admin'};
      }

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
        return null; // User not found
      }

      // Verify password
      if (user['password'] == _hashPassword(password)) {
        await _saveCurrentUser(username, user['role']);
        return {'username': username, 'role': user['role']};
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Simple password hashing (Note: In production, use a more secure hashing method)
  String _hashPassword(String password) {
    // This is a very basic hash. In a real app, use a secure hashing library
    return base64Encode(utf8.encode(password));
  }

  // Save current user with role
  Future<void> _saveCurrentUser(String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', username);
    await prefs.setString('current_user_role', role);
  }

  // Get current user with role
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('current_user'),
      'role': prefs.getString('current_user_role'),
    };
  }

  // Logout user
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_role');
    return await prefs.remove('current_user');
  }

  // Initialize default admin account
  Future<void> initializeDefaultAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_userKey) ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      // Check if default admin exists
      if (!users.any((user) => user['username'] == _defaultAdminUsername)) {
        // Create default admin account
        final defaultAdmin = {
          'username': _defaultAdminUsername,
          'password': _hashPassword(_defaultAdminPassword),
          'role': 'admin',
        };
        users.add(defaultAdmin);
        await prefs.setString(_userKey, json.encode(users));
        print('Default admin account created');
      }
    } catch (e) {
      print('Error initializing default admin: $e');
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_userKey) ?? '[]';
    final List<dynamic> users = json.decode(usersJson);
    return users.cast<Map<String, dynamic>>();
  }

  // Delete user
  Future<bool> deleteUser(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_userKey) ?? '[]';
      List<dynamic> users = json.decode(usersJson);

      // Don't allow deleting the default admin
      if (username == _defaultAdminUsername) {
        return false;
      }

      users.removeWhere((user) => user['username'] == username);
      await prefs.setString(_userKey, json.encode(users));
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole(String username, String newRole) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_userKey) ?? '[]';
      List<dynamic> users = json.decode(usersJson);

      // Don't allow modifying the default admin
      if (username == _defaultAdminUsername) {
        return false;
      }

      final userIndex = users.indexWhere((user) => user['username'] == username);
      if (userIndex != -1) {
        users[userIndex]['role'] = newRole;
        await prefs.setString(_userKey, json.encode(users));
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  // Feedback methods
  Future<void> saveFeedback(Map<String, dynamic> feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackList = prefs.getStringList('feedbacks') ?? [];
    
    feedbackList.add(jsonEncode(feedback));
    await prefs.setStringList('feedbacks', feedbackList);
  }

  Future<List<Map<String, dynamic>>> getFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackList = prefs.getStringList('feedbacks') ?? [];
    
    return feedbackList
        .map((str) => jsonDecode(str) as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));
  }
}