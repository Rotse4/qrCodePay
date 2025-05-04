import 'package:flutter/material.dart';
import 'package:qr_code/account/admin_dashboard.dart';
import '../services/account_service.dart';
import '../home.dart'; 
import 'sign_up.dart'; 
// import '../admin/admin_dashboard.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final AccountService _accountService = AccountService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAdminLogin = false;  // Track whether we're in admin login mode

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _accountService.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (result != null) {
          if (_isAdminLogin) {
            // Only allow admin login in admin mode
            if (result['role'] == 'admin') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => AdminDashboard(username: result['username'])),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('This account does not have admin privileges'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Regular user mode
            if (result['role'] == 'admin') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please use admin login for admin accounts'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => HomePage(username: result['username'])),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid username or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Title
                Text(
                  _isAdminLogin ? 'Admin Login' : 'User Login',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 32),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                          ? Icons.visibility_off 
                          : Icons.visibility
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Login Button
                _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(_isAdminLogin ? 'Admin Login' : 'User Login'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: _isAdminLogin ? Colors.red : null,
                      ),
                    ),
                SizedBox(height: 16),

                // Toggle between Admin and User login
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isAdminLogin = !_isAdminLogin;
                      // Clear the form when switching modes
                      _usernameController.clear();
                      _passwordController.clear();
                    });
                  },
                  child: Text(_isAdminLogin 
                    ? 'Switch to User Login' 
                    : 'Switch to Admin Login'),
                ),

                if (!_isAdminLogin) ...[
                  SizedBox(height: 16),
                  // Sign Up Navigation (only shown in user mode)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      );
                    },
                    child: Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}