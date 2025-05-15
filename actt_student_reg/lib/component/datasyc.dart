import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:path_provider/path_provider.dart';

class DataSync {
  List<Map<String, dynamic>> _syncedData = [];

  Future<void> loadSyncedData() async {
    // Load synced data from local storage
    try {
      final file = File(
        '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/sycdata.json',
      );
      // final directory = await getApplicationDocumentsDirectory();
      //final file = File('${directory.path}/synced_data.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        _syncedData = List<Map<String, dynamic>>.from(jsonData);
      }
    } catch (e) {
      print('Error loading synced data: $e');
    }
  }

  Future<void> saveSyncedData() async {
    // Save the synced data to a file
    try {
      final file = File(
        '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/sycdata.json',
      );
      // final directory = await getApplicationDocumentsDirectory();
      //final file = File('${directory.path}/synced_data.json');
      await file.writeAsString(jsonEncode(_syncedData));
    } catch (e) {
      print('Error saving synced data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocalData() async {
    // Fetch local data from a file for syncing to Google Sheets
    try {
      final file = File(
        '/home/mujeeb/Desktop/myflutter/actt_student_reg/lib/localstorage/student.json',
      );

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error reading local data: $e');
    }
  }

  Future<void> pushToGoogleSheet(List<Map<String, dynamic>> newData) async {
    // Push new data to Google Sheets
    try {
      // Replace with your Google Sheets API URL
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

      final body = jsonEncode({'values': rows});

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Data synced successfully!');
      } else {
        throw Exception('Failed to sync data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error pushing data to Google Sheets: $e');
    }
  }

  Future<void> syncData() async {
    try {
      await loadSyncedData();
      final localData = await fetchLocalData();

      // Find new data that hasn't been synced yet
      final newData =
          localData.where((data) {
            return !_syncedData.any(
              (synced) => synced['Student'] == data['Student'],
            );
          }).toList();

      if (newData.isNotEmpty) {
        await pushToGoogleSheet(newData);

        // Add new data to synced data list
        _syncedData.addAll(newData);

        // Save synced data locally
        await saveSyncedData();
      }

      print('Data synced successfully!');
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  void scheduleDailySync() {
    // This is a placeholder for scheduling daily sync.
    // In a real app, you would use a background service or a package like `workmanager`.
    Future.delayed(const Duration(days: 1), () {
      syncData();
      scheduleDailySync(); // Reschedule for the next day
    });
  }
}
