import 'package:flutter/material.dart';
import 'package:qr_code/account/login.dart';
import '../services/account_service.dart';

class SignUpPage extends StatefulWidget {
  final bool isAdminCreation;
  const SignUpPage({Key? key, this.isAdminCreation = false}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AccountService _accountService = AccountService();
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password validation rules
  static final _hasUppercase = RegExp(r'[A-Z]');
  static final _hasLowercase = RegExp(r'[a-z]');
  static final _hasDigit = RegExp(r'\d');
  static final _hasSpecialChar = RegExp(r'[!@#\$&*~]');
  static final _commonPasswords = {
    'password', 'admin123', '123456', 'qwerty', 'letmein',
    'welcome', 'monkey', 'football', 'abc123', '123456789',
    'dragon', 'master', 'hello', 'freedom', 'whatever',
    'qazwsx', 'trustno1', 'baseball', 'superman', 'batman',
  };

  // Password strength indicator
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    double strength = 0;
    
    // Length contribution (up to 0.25)
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.05;
    
    // Character types contribution (up to 0.5)
    if (_hasUppercase.hasMatch(password)) strength += 0.1;
    if (_hasLowercase.hasMatch(password)) strength += 0.1;
    if (_hasDigit.hasMatch(password)) strength += 0.15;
    if (_hasSpecialChar.hasMatch(password)) strength += 0.15;
    
    // Variety contribution (up to 0.25)
    final uniqueChars = password.split('').toSet().length;
    strength += (uniqueChars / password.length) * 0.25;
    
    return strength.clamp(0.0, 1.0);
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 12) {
      return 'Password must be at least 12 characters long';
    }

    if (!_hasUppercase.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!_hasLowercase.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!_hasDigit.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!_hasSpecialChar.hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$&*~)';
    }

    if (_commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger password';
    }

    // Check for sequential characters
    for (int i = 0; i < value.length - 2; i++) {
      if (value.codeUnitAt(i) + 1 == value.codeUnitAt(i + 1) &&
          value.codeUnitAt(i + 1) + 1 == value.codeUnitAt(i + 2)) {
        return 'Password cannot contain sequential characters (e.g., "abc", "123")';
      }
    }

    // Check for repeated characters
    for (int i = 0; i < value.length - 2; i++) {
      if (value[i] == value[i + 1] && value[i + 1] == value[i + 2]) {
        return 'Password cannot contain three or more repeated characters';
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeDefaultAdmin();
  }

  Future<void> _initializeDefaultAdmin() async {
    await _accountService.initializeDefaultAdmin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _accountService.signUp(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          role: _isAdmin ? 'admin' : 'user',
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isAdmin 
                ? 'Admin account created successfully!' 
                : 'Account created successfully! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Username already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
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
      appBar: AppBar(
        title: Text(_isAdmin ? 'Create Admin Account' : 'Sign Up'),
        backgroundColor: _isAdmin ? Colors.red : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title with role indication
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  _isAdmin ? 'Create Administrator Account' : 'Create User Account',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // Admin account toggle
              SwitchListTile(
                title: Text('Create Admin Account'),
                subtitle: Text(_isAdmin 
                  ? 'This account will have full administrative access'
                  : 'Switch to create an administrator account'),
                value: _isAdmin,
                activeColor: Colors.red,
                onChanged: (bool value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),

              if (_isAdmin)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Default Admin Credentials:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Username: admin'),
                      Text('Password: admin123'),
                      SizedBox(height: 8),
                      Text(
                        'You can use these credentials to access the admin dashboard.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16),

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
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password Field with Strength Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    validator: _validatePassword,
                    onChanged: (value) {
                      // Trigger rebuild for password strength indicator
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 8),
                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _calculatePasswordStrength(_passwordController.text),
                          backgroundColor: Colors.grey[200],
                          color: ColorTween(
                            begin: Colors.red,
                            end: Colors.green,
                          ).lerp(_calculatePasswordStrength(_passwordController.text)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Password Strength: ${(_calculatePasswordStrength(_passwordController.text) * 100).round()}%',
                          style: TextStyle(
                            color: ColorTween(
                              begin: Colors.red,
                              end: Colors.green,
                            ).lerp(_calculatePasswordStrength(_passwordController.text)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              // Password requirements info card
              Card(
                margin: EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• At least 12 characters long'),
                      Text('• At least one uppercase letter'),
                      Text('• At least one lowercase letter'),
                      Text('• At least one number'),
                      Text('• At least one special character (!@#\$&*~)'),
                      Text('• No sequential characters (e.g., "abc", "123")'),
                      Text('• No three repeated characters in a row'),
                      Text('• Cannot be a commonly used password'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isAdmin ? Colors.red : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isAdmin 
                        ? 'Create Admin Account'
                        : 'Create Account'
                    ),
                  ),

              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}