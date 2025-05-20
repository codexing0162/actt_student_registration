import 'package:flutter/material.dart';

class Admindrawer extends StatelessWidget {
  const Admindrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('admin@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.blue,
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Add User'),
            onTap: () {
              // Navigate to Add User screen
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Manage Users'),
            onTap: () {
              // Navigate to User List screen
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Manage Students'),
            onTap: () {
              // Navigate to Student List screen
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Manage Courses'),
            onTap: () {
              // Navigate to Course Management screen
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Reports & Analytics'),
            onTap: () {
              // Navigate to Reports screen
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Send Notification'),
            onTap: () {
              // Navigate to Notification screen
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigate to Settings screen
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
