import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/role_permissions.dart';
import 'package:uuid/uuid.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  List<User> _users = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user
      _currentUser = await _authService.getCurrentUser();
      
      // In a real app, you would load all users from a database
      // For this example, we'll use some demo users
      setState(() {
        _users = [
          User(
            id: '1',
            username: 'admin',
            password: 'admin123',
            fullName: 'Admin User',
            email: 'admin@actttraining.com',
            role: AppRole.admin,
          ),
          User(
            id: '2',
            username: 'teacher',
            password: 'teacher123',
            fullName: 'Teacher User',
            email: 'teacher@actttraining.com',
            role: AppRole.teacher,
          ),
          User(
            id: '3',
            username: 'accounting',
            password: 'accounting123',
            fullName: 'Accounting User',
            email: 'accounting@actttraining.com',
            role: AppRole.accounting,
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Add or edit a user
  Future<void> _showUserForm({User? user}) async {
    final result = await showDialog<User>(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );
    
    if (result != null) {
      try {
        // In a real app, you would save the user to a database
        // For this example, we'll just update the local state
        setState(() {
          if (user == null) {
            // Add new user
            _users.add(result);
          } else {
            // Update existing user
            final index = _users.indexWhere((u) => u.id == user.id);
            if (index >= 0) {
              _users[index] = result;
            }
          }
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user == null ? 'User added' : 'User updated'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error saving user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Toggle user active status
  void _toggleUserStatus(User user) {
    if (user.id == _currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot disable your own account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _users[index] = user.copyWith(isActive: !user.isActive);
      }
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.isActive ? 'User deactivated' : 'User activated',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add New User'),
                        onPressed: () => _showUserForm(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isCurrentUser = user.id == _currentUser?.id;
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role),
                          child: Text(user.initials),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${user.username}'),
                            Text(
                              user.roleDisplayName,
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: user.isActive ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Actions menu
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showUserForm(user: user);
                                    break;
                                  case 'toggle':
                                    _toggleUserStatus(user);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit User'),
                                ),
                                if (!isCurrentUser)
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(user.isActive
                                        ? 'Disable Account'
                                        : 'Enable Account'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showUserForm(user: user),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add User',
        onPressed: () => _showUserForm(),
      ),
    );
  }
  
  // Get color for role
  Color _getRoleColor(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return Colors.purple;
      case AppRole.teacher:
        return Colors.blue;
      case AppRole.accounting:
        return Colors.green;
    }
  }
}

// User form dialog
class UserFormDialog extends StatefulWidget {
  final User? user;
  
  const UserFormDialog({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  AppRole _role = AppRole.teacher;
  bool _isActive = true;
  bool _isEditingPassword = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.user != null) {
      // Populate form with user data
      _usernameController.text = widget.user!.username;
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phoneNumber ?? '';
      _role = widget.user!.role;
      _isActive = widget.user!.isActive;
      _isEditingPassword = false;
    } else {
      // Default values for new user
      _isEditingPassword = true;
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  // Save form
  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    
    final user = User(
      id: widget.user?.id ?? Uuid().v4(),
      username: _usernameController.text.trim(),
      password: _isEditingPassword
          ? _passwordController.text
          : widget.user!.password,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: _role,
      isActive: _isActive,
      lastLogin: widget.user?.lastLogin,
    );
    
    Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: widget.user == null, // Can't change username for existing user
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Password
                if (widget.user == null)
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  )
                else
                  Row(
                    children: [
                      Checkbox(
                        value: _isEditingPassword,
                        onChanged: (value) {
                          setState(() {
                            _isEditingPassword = value ?? false;
                          });
                        },
                      ),
                      Text('Change password'),
                      Spacer(),
                    ],
                  ),
                if (widget.user != null && _isEditingPassword)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (_isEditingPassword && (value == null || value.isEmpty)) {
                          return 'Please enter a new password';
                        }
                        if (_isEditingPassword && value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                SizedBox(height: 16),
                
                // Full name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                
                // Role selection
                Text(
                  'Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildRoleSelector(),
                SizedBox(height: 16),
                
                // Active status
                CheckboxListTile(
                  title: Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Role description
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role Permissions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(RolePermissions.getRoleDescription(_role)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.user == null ? 'Add User' : 'Save Changes'),
          onPressed: _saveForm,
        ),
      ],
    );
  }
  
  // Build role selector radio buttons
  Widget _buildRoleSelector() {
    return Column(
      children: [
        RadioListTile<AppRole>(
          title: Text('Administrator'),
          value: AppRole.admin,
          groupValue: _role,
          onChanged: (value) {
            setState(() {
              _role = value!;
            });
          },
          secondary: CircleAvatar(
            backgroundColor: Colors.purple,
            radius: 15,
            child: Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
          ),
        ),
        RadioListTile<AppRole>(
          title: Text('Teacher'),
          value: AppRole.teacher,
          groupValue: _role,
          onChanged: (value) {
            setState(() {
              _role = value!;
            });
          },
          secondary: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 15,
            child: Icon(Icons.school, size: 16, color: Colors.white),
          ),
        ),
        RadioListTile<AppRole>(
          title: Text('Accounting/Sales'),
          value: AppRole.accounting,
          groupValue: _role,
          onChanged: (value) {
            setState(() {
              _role = value!;
            });
          },
          secondary: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 15,
            child: Icon(Icons.attach_money, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}