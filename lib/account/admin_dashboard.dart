import 'package:flutter/material.dart';
import 'package:qr_code/account/sign_up.dart';
import 'package:qr_code/home.dart';
import '../services/account_service.dart';
import 'login.dart';

class AdminDashboard extends StatefulWidget {
  final String username;
  const AdminDashboard({Key? key, required this.username}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AccountService _accountService = AccountService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  Future<List<Map<String, dynamic>>> _loadFeedback() async {
    final feedback = await _accountService.getFeedback();
    return feedback;
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _accountService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _logout() async {
    await _accountService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Future<void> _deleteUser(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete user "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _accountService.deleteUser(username);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
        _loadUsers(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delete this user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserRole(String username, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Role Change'),
        content: Text(
          'Are you sure you want to change $username\'s role to $newRole?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Change Role'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _accountService.updateUserRole(username, newRole);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated successfully')),
        );
        _loadUsers(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot modify this user\'s role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  // Welcome section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Welcome, ${widget.username}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HomePage(username: widget.username),
                          ),
                        ),
                        child: Text('HomePage'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // User Management Section
                  Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'User Management',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final isDefaultAdmin = user['username'] == 'admin';
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: user['role'] == 'admin' 
                                  ? Colors.red 
                                  : Colors.blue,
                                child: Icon(
                                  user['role'] == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                user['username'],
                                style: TextStyle(
                                  fontWeight: isDefaultAdmin 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                'Role: ${user['role']}${isDefaultAdmin ? ' (Default)' : ''}',
                              ),
                              trailing: !isDefaultAdmin ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Role toggle button
                                  IconButton(
                                    icon: Icon(
                                      user['role'] == 'admin'
                                        ? Icons.admin_panel_settings
                                        : Icons.person_outline,
                                    ),
                                    onPressed: () => _toggleUserRole(
                                      user['username'],
                                      user['role'],
                                    ),
                                    tooltip: 'Toggle admin role',
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _deleteUser(user['username']),
                                    tooltip: 'Delete user',
                                  ),
                                ],
                              ) : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Feedback Section
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Customer Feedback',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _loadFeedback(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No feedback yet'),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (_, __) => Divider(height: 1),
                              itemBuilder: (context, index) {
                                final feedback = snapshot.data![index];
                                return ListTile(
                                  title: Text(feedback['title']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(feedback['feedback']),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Rating: ${feedback['rating'].round()} ★',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          Text('by ${feedback['username']}'),
                                          Spacer(),
                                          Text(
                                            DateTime.parse(feedback['timestamp'])
                                                .toLocal()
                                                .toString()
                                                .split('.')[0],
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SignUpPage(isAdminCreation: true),
            ),
          ).then((_) => _loadUsers()); // Refresh list after returning
        },
        label: Text('Add Admin'),
        icon: Icon(Icons.person_add),
        backgroundColor: Colors.red,
      ),
    );
  }
}