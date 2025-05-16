import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../screens/home.dart';
import '../screens/studentlist.dart';
import '../screens/payment_tracking.dart';
import '../screens/graduated_students.dart';
import '../screens/statistics_dashboard.dart';
import '../screens/course_management.dart';
import '../screens/user_management.dart';
import '../screens/setting.dart';
import '../screens/sync_history.dart';
import '../utils/role_permissions.dart';

class AppDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userRole = user?.role ?? AppRole.teacher; // Default to teacher permissions
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer header with app logo and user info
              _buildDrawerHeader(user),
              
              // Home
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Home',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                ),
              ),
              
              // Student Management
              _buildSectionHeader('Student Management'),
              
              // Student List (all roles)
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Student List',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentListScreen()),
                ),
              ),
              
              // Graduated Students (all roles)
              _buildDrawerItem(
                icon: Icons.school,
                title: 'Graduated Students',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GraduatedStudentsScreen()),
                ),
              ),
              
              // Financial Management
              _buildSectionHeader('Financial Management'),
              
              // Payment Tracking (admin and accounting roles)
              if (RolePermissions.canAccessPayments(userRole))
                _buildDrawerItem(
                  icon: Icons.payments,
                  title: 'Payment Tracking',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentTrackingScreen()),
                  ),
                ),
              
              // Reporting & Analytics
              _buildSectionHeader('Reporting & Analytics'),
              
              // Statistics Dashboard (admin and teacher roles)
              if (RolePermissions.canAccessStatistics(userRole))
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Statistics Dashboard',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticsDashboardScreen()),
                  ),
                ),
              
              // Administration
              if (userRole == AppRole.admin)
                _buildSectionHeader('Administration'),
              
              // Course Management (admin only)
              if (userRole == AppRole.admin)
                _buildDrawerItem(
                  icon: Icons.book,
                  title: 'Course Management',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CourseManagementScreen()),
                  ),
                ),
              
              // User Management (admin only)
              if (userRole == AppRole.admin)
                _buildDrawerItem(
                  icon: Icons.admin_panel_settings,
                  title: 'User Management',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementScreen()),
                  ),
                ),
              
              // Settings & Support
              _buildSectionHeader('Settings & Support'),
              
              // Settings (all roles)
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen()),
                ),
              ),
              
              // Sync History (all roles)
              _buildDrawerItem(
                icon: Icons.sync,
                title: 'Sync History',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SyncHistoryScreen()),
                ),
              ),
              
              // Logout
              Divider(),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  await _authService.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build drawer header with user info
  Widget _buildDrawerHeader(User? user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo
          Image.asset(
            'lib/images/acttlogo.png',
            height: 60,
            width: 60,
          ),
          SizedBox(height: 10),
          // App Name
          Text(
            'ACTT Registration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // User info if logged in
          if (user != null)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  radius: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getRoleText(user.role),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // Build a drawer item with icon and title
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
  
  // Build section header in drawer
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  // Get human-readable role text
  String _getRoleText(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Administrator';
      case AppRole.teacher:
        return 'Teacher';
      case AppRole.accounting:
        return 'Accounting / Sales';
      default:
        return 'Staff';
    }
  }
}