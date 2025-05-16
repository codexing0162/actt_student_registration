import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../components/datasyc_manager.dart';

class SyncHistoryScreen extends StatefulWidget {
  @override
  _SyncHistoryScreenState createState() => _SyncHistoryScreenState();
}

class _SyncHistoryScreenState extends State<SyncHistoryScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  late GoogleSheetsService _googleSheetsService;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _syncEvents = [];
  bool _isSyncRequired = false;

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _loadSyncHistory();
  }
  
  Future<void> _loadSyncHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load sync events
      final syncEvents = await _localStorageService.getSyncEvents();
      
      // Check if sync is required
      final isSyncRequired = await _localStorageService.isSyncRequired();
      
      setState(() {
        _syncEvents = syncEvents;
        _isSyncRequired = isSyncRequired;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading sync history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Open sync manager
  void _openSyncManager() {
    showDialog(
      context: context,
      builder: (context) => DataSyncManager(
        onSyncComplete: () {
          _loadSyncHistory();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync History'),
        actions: [
          // Sync button
          IconButton(
            icon: Icon(Icons.sync),
            tooltip: 'Sync Now',
            onPressed: _openSyncManager,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sync status card
                Card(
                  margin: EdgeInsets.all(16),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isSyncRequired ? Icons.sync_problem : Icons.sync,
                              color: _isSyncRequired ? Colors.orange : Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sync Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isSyncRequired
                              ? 'Sync required. You have pending changes that need to be uploaded.'
                              : 'No sync required. Your data is up to date.',
                          style: TextStyle(
                            color: _isSyncRequired ? Colors.orange : Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pending changes: ${_syncEvents.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_isSyncRequired || _syncEvents.isNotEmpty)
                          ElevatedButton.icon(
                            icon: Icon(Icons.sync),
                            label: Text('Sync Now'),
                            onPressed: _openSyncManager,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Pending changes list
                Expanded(
                  child: _syncEvents.isEmpty
                      ? Center(
                          child: Text(
                            'No pending changes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _syncEvents.length,
                          itemBuilder: (context, index) {
                            final event = _syncEvents[index];
                            
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: _getIconForEventType(event['type']),
                                title: Text(_getDescriptionForEvent(event)),
                                subtitle: Text(
                                  Formatters.formatDateTime(
                                    DateTime.parse(event['timestamp']),
                                  ),
                                ),
                                trailing: Chip(
                                  label: Text(
                                    event['type'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: _getColorForEventType(event['type']),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        onPressed: _loadSyncHistory,
      ),
    );
  }
  
  // Get icon for event type
  Widget _getIconForEventType(String type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case 'ADD':
        iconData = Icons.add_circle;
        color = Colors.green;
        break;
      case 'UPDATE':
        iconData = Icons.edit;
        color = Colors.blue;
        break;
      case 'DELETE':
        iconData = Icons.delete;
        color = Colors.red;
        break;
      case 'PAYMENT':
        iconData = Icons.payment;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.sync;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
  
  // Get color for event type
  Color _getColorForEventType(String type) {
    switch (type) {
      case 'ADD':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      case 'PAYMENT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  // Get description for event
  String _getDescriptionForEvent(Map<String, dynamic> event) {
    final type = event['type'];
    final data = event['data'];
    
    switch (type) {
      case 'ADD':
        return 'Add student: ${data['fullName'] ?? 'Unknown'}';
      case 'UPDATE':
        return 'Update student: ${data['fullName'] ?? 'Unknown'}';
      case 'DELETE':
        return 'Delete student: ${data['fullName'] ?? 'Unknown'}';
      case 'PAYMENT':
        return 'Payment of \$${data['amount']} for student ID ${data['studentId']}';
      default:
        return type;
    }
  }
}