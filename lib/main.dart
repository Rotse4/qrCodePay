import 'package:flutter/material.dart';
import 'package:qr_code/home.dart';
import 'package:qr_code/account/login.dart';
import 'package:qr_code/services/account_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AccountService _accountService = AccountService();
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final currentUser = await _accountService.getCurrentUser();
      setState(() {
        _isLoggedIn = currentUser['username'] != null;
        _username = currentUser['username'];  // Extract just the username from the map
        _isCheckingAuth = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _username = null;
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Customize app-wide text styles
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        // Customize button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: _isCheckingAuth
          ? _buildLoadingScreen()
          : _isLoggedIn
              ? HomePage(username: _username!)  // Pass the username
              : const LoginPage(),
    );
  }

  // Loading screen while checking authentication status
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
