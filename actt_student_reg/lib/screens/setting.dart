import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../component/nofticationtheme.dart'; // Import ThemeNotifier
import '../component/datasyc.dart'; // Assuming DataSync is implemented in this file

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _autoSyncEnabled = false; // State variable for auto sync

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Sync Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text('Manual Sync'),
            subtitle: const Text('Sync data with Google Sheets manually'),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  await DataSync().syncData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data synced successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error syncing data: $e')),
                  );
                }
              },
              child: const Text('Sync Now'),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Auto Sync'),
            subtitle: const Text('Automatically sync data daily'),
            value: _autoSyncEnabled,
            onChanged: (bool value) {
              setState(() {
                _autoSyncEnabled = value;
              });
              if (value) {
                DataSync().scheduleDailySync();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto Sync Enabled')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto Sync Disabled')),
                );
              }
            },
          ),
          const Divider(),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text('Clear Local Data'),
            subtitle: const Text('Delete all local data'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  final studentFile = File(
                    '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/student.json',
                  );
                  final syncedFile = File(
                    '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/sycdata.json',
                  );

                  if (await studentFile.exists()) await studentFile.delete();
                  if (await syncedFile.exists()) await syncedFile.delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Local data cleared successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error clearing data: $e')),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export local data as JSON or CSV'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                try {
                  final studentFile = File(
                    '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/student.json',
                  );

                  if (await studentFile.exists()) {
                    final data = await studentFile.readAsString();

                    final exportFile = File(
                      '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/exported.json',
                    );
                    await exportFile.writeAsString(data);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data exported successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No data to export!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error exporting data: $e')),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Import data from a JSON or CSV file'),
            trailing: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () async {
                try {
                  final importFile = File(
                    '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/imported.json',
                  );

                  if (await importFile.exists()) {
                    final studentFile = File(
                      '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/student.json',
                    );
                    final data = await importFile.readAsString();
                    await studentFile.writeAsString(data);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data imported successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No imported file found!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error importing data: $e')),
                  );
                }
              },
            ),
          ),
          const Divider(),
          const Text(
            'Theme Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value:
                Provider.of<ThemeNotifier>(
                  context,
                ).isDarkMode, // Access ThemeNotifier
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
          const Text(
            'App Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
