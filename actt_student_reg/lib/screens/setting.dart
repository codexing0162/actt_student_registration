
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../components/datasyc_manager.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _googleScriptUrlController = TextEditingController();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  bool _autoSync = true;
  bool _darkMode = false;
  bool _isTestingConnection = false;
  bool _connectionStatus = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _googleScriptUrlController.text = Constants.googleScriptUrl;
    _autoSync = await Constants.getAutoSync();
    _darkMode = await Constants.getDarkMode();
    setState(() {});
  }

  @override
  void dispose() {
    _googleScriptUrlController.dispose();
    super.dispose();
  }
  
  // Save Google Script URL
  Future<void> _saveGoogleScriptUrl() async {
    if (!_formKey.currentState!.validate()) return;
    
    final url = _googleScriptUrlController.text.trim();
    await Constants.saveGoogleScriptUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Script URL saved'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Test connection to Google Sheets
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
    });
    
    try {
      final googleSheetsService = GoogleSheetsService(
        _localStorageService, 
        _googleScriptUrlController.text.trim(),
      );
      
      final success = await googleSheetsService.testConnection();
      
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = success;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connection successful!' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing connection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Toggle auto-sync
  Future<void> _toggleAutoSync(bool value) async {
    await Constants.saveAutoSync(value);
    setState(() {
      _autoSync = value;
    });
  }
  
  // Toggle dark mode
  Future<void> _toggleDarkMode(bool value) async {
    await Constants.saveDarkMode(value);
    setState(() {
      _darkMode = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode will be applied on restart'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Sheets Integration
              _buildSectionHeader('Google Sheets Integration'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _googleScriptUrlController,
                      decoration: InputDecoration(
                        labelText: 'Google Script URL',
                        hintText: 'https://script.google.com/macros/s/...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a URL';
                        }
                        if (!value.startsWith('https://')) {
                          return 'URL must start with https://';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: Text('Save URL'),
                            onPressed: _saveGoogleScriptUrl,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: _isTestingConnection
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(_connectionStatus ? Icons.check : Icons.sync),
                            label: Text('Test Connection'),
                            onPressed: _isTestingConnection ? null : _testConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _connectionStatus ? Colors.green : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Data Synchronization
              _buildSectionHeader('Data Synchronization'),
              ListTile(
                title: Text('Auto-sync when online'),
                subtitle: Text(
                  'Automatically sync data with Google Sheets when an internet connection is available'
                ),
                trailing: Switch(
                  value: _autoSync,
                  onChanged: _toggleAutoSync,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.sync),
                label: Text('Sync Now'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DataSyncManager(
                      onSyncComplete: () {
                        // Do nothing
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 24),
              
              // Appearance
              _buildSectionHeader('Appearance'),
              ListTile(
                title: Text('Dark Mode'),
                subtitle: Text('Use dark theme throughout the app'),
                trailing: Switch(
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                ),
              ),
              SizedBox(height: 24),
              
              // About
              _buildSectionHeader('About'),
              ListTile(
                title: Text('App Version'),
                subtitle: Text(Constants.appVersion),
                trailing: Icon(Icons.info_outline),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constants.appName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This application manages student registrations, courses, and payments for ACTT Training Center.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        'For more help, contact the developer: mujeeb',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }
}