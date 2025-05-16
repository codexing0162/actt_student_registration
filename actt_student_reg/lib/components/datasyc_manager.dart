import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../utils/constants.dart';

// Component to handle data synchronization between local storage and Google Sheets
class DataSyncManager extends StatefulWidget {
  final VoidCallback onSyncComplete;
  
  const DataSyncManager({
    Key? key, 
    required this.onSyncComplete,
  }) : super(key: key);

  @override
  _DataSyncManagerState createState() => _DataSyncManagerState();
}

class _DataSyncManagerState extends State<DataSyncManager> {
  final LocalStorageService _localStorageService = LocalStorageService();
  late GoogleSheetsService _googleSheetsService;
  
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isSyncing = false;
  String _statusMessage = 'Checking connection...';
  int _pendingSyncEvents = 0;
  bool _syncRequired = false;

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _checkConnection();
  }
  
  // Check connection to Google Sheets and count pending sync events
  Future<void> _checkConnection() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Checking connection...';
    });
    
    try {
      // Test connection to Google Sheets
      final isConnected = await _googleSheetsService.testConnection();
      
      // Count pending sync events
      final syncEvents = await _localStorageService.getSyncEvents();
      final isSyncRequired = await _localStorageService.isSyncRequired();
      
      setState(() {
        _isConnected = isConnected;
        _isConnecting = false;
        _pendingSyncEvents = syncEvents.length;
        _syncRequired = isSyncRequired;
        
        if (isConnected) {
          _statusMessage = syncEvents.isEmpty
              ? 'Connected. No pending changes to sync.'
              : 'Connected. ${syncEvents.length} pending changes to sync.';
        } else {
          _statusMessage = 'Not connected to Google Sheets. Working offline.';
        }
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _statusMessage = 'Error checking connection: $e';
      });
    }
  }
  
  // Sync pending changes to Google Sheets
  Future<void> _syncData() async {
    if (!_isConnected || _pendingSyncEvents == 0) return;
    
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Syncing data...';
    });
    
    try {
      // Sync pending operations
      final successCount = await _googleSheetsService.syncPendingOperations();
      
      // Refresh counts
      final syncEvents = await _localStorageService.getSyncEvents();
      final isSyncRequired = await _localStorageService.isSyncRequired();
      
      setState(() {
        _isSyncing = false;
        _pendingSyncEvents = syncEvents.length;
        _syncRequired = isSyncRequired;
        
        if (successCount > 0) {
          _statusMessage = 'Synced $successCount changes successfully. '
              '${syncEvents.length} changes remaining.';
        } else {
          _statusMessage = 'No changes were synced. '
              '${syncEvents.length} changes pending.';
        }
      });
      
      // Call parent callback to refresh data
      widget.onSyncComplete();
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'Error syncing data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Data Synchronization'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection status
          Row(
            children: [
              Icon(
                _isConnecting
                    ? Icons.sync
                    : _isConnected
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                color: _isConnecting
                    ? Colors.blue
                    : _isConnected
                        ? Colors.green
                        : Colors.red,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isConnecting
                      ? 'Checking connection...'
                      : _isConnected
                          ? 'Connected to Google Sheets'
                          : 'Not connected. Working offline.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isConnecting
                        ? Colors.blue
                        : _isConnected
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Pending changes info
          if (!_isConnecting) ...[
            Text(
              'Pending Changes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Changes waiting to sync:'),
                Text(
                  '$_pendingSyncEvents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _pendingSyncEvents > 0 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sync required:'),
                Text(
                  _syncRequired ? 'Yes' : 'No',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _syncRequired ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Status message
            Text(
              _statusMessage,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
          
          // Show spinner when connecting or syncing
          if (_isConnecting || _isSyncing) ...[
            SizedBox(height: 16),
            Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (_isConnected && _pendingSyncEvents > 0 && !_isSyncing)
          ElevatedButton.icon(
            icon: Icon(Icons.sync),
            label: Text('Sync Now'),
            onPressed: _syncData,
          ),
        if (!_isConnected && !_isConnecting)
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Retry Connection'),
            onPressed: _checkConnection,
          ),
      ],
    );
  }
}