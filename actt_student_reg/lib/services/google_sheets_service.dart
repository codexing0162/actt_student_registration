import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../utils/constants.dart';
import '../services/local_storage_service.dart';

class GoogleSheetsService {
  final LocalStorageService _localStorageService;
  final String _scriptUrl;
  
  // Constructor with dependency injection
  GoogleSheetsService(this._localStorageService, this._scriptUrl);
  
  // Fetch all students from Google Sheets
  Future<List<Student>> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('$_scriptUrl?action=getStudents'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Student.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load students. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      // If online fetch fails, return locally stored students
      return await _localStorageService.getStudents();
    }
  }
  
  // Add a new student to Google Sheets
  Future<bool> addStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$_scriptUrl?action=addStudent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(student.toJson()),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to add student. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding student: $e');
      // Store failed operation for syncing later
      await _localStorageService.addSyncEvent({
        'type': 'ADD',
        'data': student.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }
  
  // Update an existing student in Google Sheets
  Future<bool> updateStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$_scriptUrl?action=updateStudent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': student.id, ...student.toJson()}),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update student. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating student: $e');
      // Store failed operation for syncing later
      await _localStorageService.addSyncEvent({
        'type': 'UPDATE',
        'data': student.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }
  
  // Record payment for a student
  Future<bool> recordPayment(String studentId, double amount, String description) async {
    try {
      final payment = {
        'studentId': studentId,
        'amount': amount,
        'description': description,
        'date': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(
        Uri.parse('$_scriptUrl?action=recordPayment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment),
      );
      
      if (response.statusCode == 200) {
        // Update local student record
        final student = await _localStorageService.getStudentById(studentId);
        if (student != null) {
          final updatedStudent = student.copyWith(
            amountPaid: student.amountPaid + amount,
            remainingPrice: student.remainingPrice - amount,
          );
          await _localStorageService.updateStudent(updatedStudent);
        }
        return true;
      } else {
        throw Exception('Failed to record payment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error recording payment: $e');
      // Store failed operation for syncing later
      await _localStorageService.addSyncEvent({
        'type': 'PAYMENT',
        'data': {
          'studentId': studentId,
          'amount': amount,
          'description': description,
          'date': DateTime.now().toIso8601String(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }
  
  // Sync pending operations to Google Sheets
  Future<int> syncPendingOperations() async {
    final pendingOperations = await _localStorageService.getSyncEvents();
    int successCount = 0;
    
    for (final operation in pendingOperations) {
      bool success = false;
      
      switch (operation['type']) {
        case 'ADD':
          final student = Student.fromJson(operation['data']);
          success = await addStudent(student);
          break;
        case 'UPDATE':
          final student = Student.fromJson(operation['data']);
          success = await updateStudent(student);
          break;
        case 'PAYMENT':
          final payment = operation['data'];
          success = await recordPayment(
            payment['studentId'],
            payment['amount'],
            payment['description'],
          );
          break;
      }
      
      if (success) {
        await _localStorageService.removeSyncEvent(operation);
        successCount++;
      } else {
        // Stop syncing if we hit a failure
        break;
      }
    }
    
    return successCount;
  }
  
  // Test connection to Google Sheets
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$_scriptUrl?action=test'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error testing connection: $e');
      return false;
    }
  }
}