import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:actt_student_reg/screens/home.dart';
import 'package:actt_student_reg/screens/setting.dart';
import 'package:actt_student_reg/screens/studentlist.dart';
import 'package:actt_student_reg/component/nofticationtheme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueGrey),
            child: Image.asset('lib/images/acttlogo.png'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const homepage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Student List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentList()),
              );
            },
          ),
          /* ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Setting'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Setting()),
              );
            },
          ),*/
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: Provider.of<ThemeNotifier>(context).isDarkMode,
            onChanged: (bool value) {
              Provider.of<ThemeNotifier>(
                context,
                listen: false,
              ).toggleTheme(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Dark Mode Enabled' : 'Dark Mode Disabled',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Learn more about the app'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Student Registration App',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 actt',
                children: [
                  const Text('Developed by Mujeeb Abdul'),
                  const SizedBox(height: 8),
                  const Text(
                    'This app is designed to help manage student registrations.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('View the app\'s privacy policy'),
            onTap: () {
              const url = 'https://your-privacy-policy-url.com';
              launchUrl(Uri.parse(url));
            },
          ),
        ],
      ),
    );
  }
}
