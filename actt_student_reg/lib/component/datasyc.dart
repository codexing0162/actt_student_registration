import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class DataSync {
  List<Map<String, dynamic>> _syncedData = [];

  // Load already-synced data from local JSON
  Future<void> loadSyncedData() async {
    try {
      final file = File('lib/localstorage/sycdata.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        _syncedData = List<Map<String, dynamic>>.from(jsonData);
      }
    } catch (e) {
      print('Error loading synced data: $e');
    }
  }

  // Save synced data to file
  Future<void> saveSyncedData() async {
    try {
      final file = File('lib/localstorage/sycdata.json');
      await file.writeAsString(jsonEncode(_syncedData));
    } catch (e) {
      print('Error saving synced data: $e');
    }
  }

  // Fetch data from students.json (local asset)
  Future<List<Map<String, dynamic>>> fetchLocalData() async {
    try {
      final content = await rootBundle.loadString(
        'lib/localstorage/students.json',
      );
      final List<dynamic> jsonData = jsonDecode(content);
      return List<Map<String, dynamic>>.from(jsonData);
    } catch (e) {
      throw Exception('Error reading local data: $e');
    }
  }

  // Push new records to Google Sheets
  Future<void> pushToGoogleSheet(List<Map<String, dynamic>> newData) async {
    try {
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycby2HTo4nmtn0yGKvAb3xlF9NNJFQWFFOxeT_o9lrM4tb5riN4_5UYjVRiOBmRk7XlzE/exec',
      );

      final rows =
          newData.map((data) {
            return [
              data['Student'],
              data['fullName'],
              data['dob'],
              data['gender'],
              data['postalAddress'],
              data['phone'],
              data['emergencyPhone'],
              data['educationLevel'],
              data['courseName'],
              data['trainerName'],
              data['admissionDate'],
              data['completionDate'],
              data['duration'],
              data['price'],
              data['amountPaid'],
              data['remainingPrice'],
            ];
          }).toList();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'values': rows}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sync data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error pushing data to Google Sheets: $e');
    }
  }

  // Perform full sync
  Future<void> syncData() async {
    try {
      await loadSyncedData();
      final localData = await fetchLocalData();

      final newData =
          localData.where((data) {
            return !_syncedData.any(
              (synced) => synced['Student'] == data['Student'],
            );
          }).toList();

      if (newData.isNotEmpty) {
        await pushToGoogleSheet(newData);
        _syncedData.addAll(newData);
        await saveSyncedData();
      }

      print('✅ Data synced successfully!');
    } catch (e) {
      print('❌ Error syncing data: $e');
    }
  }

  // Optional: simulate daily sync
  void scheduleDailySync() {
    Future.delayed(const Duration(days: 1), () {
      syncData();
      scheduleDailySync();
    });
  }
}
