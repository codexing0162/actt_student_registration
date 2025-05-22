import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String _studentdatapath = 'lib/localstorage/students.json';

class DataSync {
  Future<String> pushAndDeleteStudentData() async {
    try {
      final file = File(_studentdatapath);
      if (!await file.exists()) {
        return '❌ student.json file not found.';
      }

      final content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);
      if (jsonData.isEmpty) {
        return '⚠️ No student data to sync.';
      }

      final List<Map<String, dynamic>> students =
          List<Map<String, dynamic>>.from(jsonData);

      final rows =
          students
              .map(
                (data) => [
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
                ],
              )
              .toList();

      final response = await http.post(
        Uri.parse(
          'https://script.google.com/macros/s/AKfycbySt_PdLxKtje6gW5YlP2IdUOgKJpd3wl6HalvyEulZ_ft52-QKoRf3bYRth7cD64d6/exec',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'values': rows}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          await file.delete();
          return '✅ ${body['message']}';
        } else {
          return '⚠️ Server Error: ${body['message']}';
        }
      } else {
        return '❌ HTTP Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      // Handle any exceptions
      return '❌ Error: $e';
    }
  }
}
