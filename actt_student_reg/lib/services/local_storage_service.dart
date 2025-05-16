import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';
import '../models/sync_event.dart';
import '../models/payment.dart';
import '../models/course.dart';
import '../models/user.dart';

class LocalStorageService {
  // Maximum number of sync events to store before requiring sync
  static const int MAX_SYNC_EVENTS = 3;
  
  // Get application directory for file storage
  Future<Directory> get _appDir async => 
      await getApplicationDocumentsDirectory();
  
  // File paths
  Future<File> get _studentsFile async => 
      File('${(await _appDir).path}/students.json');
  
  Future<File> get _paymentsFile async => 
      File('${(await _appDir).path}/payments.json');
  
  Future<File> get _syncEventsFile async => 
      File('${(await _appDir).path}/sync_events.json');
  
  Future<File> get _coursesFile async => 
      File('${(await _appDir).path}/courses.json');
  
  Future<File> get _usersFile async => 
      File('${(await _appDir).path}/users.json');
  
  // Create file if it doesn't exist
  Future<File> _ensureFileExists(Future<File> fileGetter, String defaultContent) async {
    final file = await fileGetter;
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(defaultContent);
    }
    return file;
  }
  
  // === STUDENTS ===
  
  // Get all students
  Future<List<Student>> getStudents() async {
    try {
      final file = await _ensureFileExists(_studentsFile, '[]');
      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((data) => Student.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error reading students: $e');
      return [];
    }
  }
  
  // Save all students
  Future<void> saveStudents(List<Student> students) async {
    try {
      final file = await _ensureFileExists(_studentsFile, '[]');
      final content = json.encode(students.map((s) => s.toJson()).toList());
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('Error saving students: $e');
    }
  }
  
  // Get student by ID
  Future<Student?> getStudentById(String id) async {
    try {
      final students = await getStudents();
      return students.firstWhere((s) => s.id == id);
    } catch (e) {
      debugPrint('Error getting student by ID: $e');
      return null;
    }
  }
  
  // Add a single student
  Future<void> addStudent(Student student) async {
    try {
      final students = await getStudents();
      students.add(student);
      await saveStudents(students);
    } catch (e) {
      debugPrint('Error adding student: $e');
    }
  }
  
  // Update a student
  Future<void> updateStudent(Student student) async {
    try {
      final students = await getStudents();
      final index = students.indexWhere((s) => s.id == student.id);
      if (index >= 0) {
        students[index] = student;
        await saveStudents(students);
      }
    } catch (e) {
      debugPrint('Error updating student: $e');
    }
  }
  
  // === PAYMENTS ===
  
  // Get all payments
  Future<List<Payment>> getPayments() async {
    try {
      final file = await _ensureFileExists(_paymentsFile, '[]');
      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((data) => Payment.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error reading payments: $e');
      return [];
    }
  }
  
  // Add a payment
  Future<void> addPayment(Payment payment) async {
    try {
      final payments = await getPayments();
      payments.add(payment);
      final file = await _ensureFileExists(_paymentsFile, '[]');
      final content = json.encode(payments.map((p) => p.toJson()).toList());
      await file.writeAsString(content);
      
      // Update student's payment info
      final student = await getStudentById(payment.studentId);
      if (student != null) {
        final updatedStudent = student.copyWith(
          amountPaid: student.amountPaid + payment.amount,
          remainingPrice: student.remainingPrice - payment.amount,
        );
        await updateStudent(updatedStudent);
      }
    } catch (e) {
      debugPrint('Error adding payment: $e');
    }
  }
  
  // Get payments for a specific student
  Future<List<Payment>> getPaymentsForStudent(String studentId) async {
    try {
      final payments = await getPayments();
      return payments.where((p) => p.studentId == studentId).toList();
    } catch (e) {
      debugPrint('Error getting payments for student: $e');
      return [];
    }
  }
  
  // === SYNC EVENTS ===
  
  // Get all sync events
  Future<List<Map<String, dynamic>>> getSyncEvents() async {
    try {
      final file = await _ensureFileExists(_syncEventsFile, '[]');
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    } catch (e) {
      debugPrint('Error reading sync events: $e');
      return [];
    }
  }
  
  // Add a sync event
  Future<void> addSyncEvent(Map<String, dynamic> event) async {
    try {
      final events = await getSyncEvents();
      events.add(event);
      final file = await _ensureFileExists(_syncEventsFile, '[]');
      await file.writeAsString(json.encode(events));
    } catch (e) {
      debugPrint('Error adding sync event: $e');
    }
  }
  
  // Remove a sync event
  Future<void> removeSyncEvent(Map<String, dynamic> event) async {
    try {
      final events = await getSyncEvents();
      events.removeWhere((e) => 
          e['type'] == event['type'] && 
          e['timestamp'] == event['timestamp']);
      final file = await _ensureFileExists(_syncEventsFile, '[]');
      await file.writeAsString(json.encode(events));
    } catch (e) {
      debugPrint('Error removing sync event: $e');
    }
  }
  
  // Check if sync is required
  Future<bool> isSyncRequired() async {
    final events = await getSyncEvents();
    return events.length >= MAX_SYNC_EVENTS;
  }
  
  // === COURSES ===
  
  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final file = await _ensureFileExists(_coursesFile, '[]');
      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((data) => Course.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error reading courses: $e');
      return [];
    }
  }
  
  // Save all courses
  Future<void> saveCourses(List<Course> courses) async {
    try {
      final file = await _ensureFileExists(_coursesFile, '[]');
      final content = json.encode(courses.map((c) => c.toJson()).toList());
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('Error saving courses: $e');
    }
  }
  
  // Add a course
  Future<void> addCourse(Course course) async {
    try {
      final courses = await getCourses();
      courses.add(course);
      await saveCourses(courses);
    } catch (e) {
      debugPrint('Error adding course: $e');
    }
  }
  
  // Update a course
  Future<void> updateCourse(Course course) async {
    try {
      final courses = await getCourses();
      final index = courses.indexWhere((c) => c.id == course.id);
      if (index >= 0) {
        courses[index] = course;
        await saveCourses(courses);
      }
    } catch (e) {
      debugPrint('Error updating course: $e');
    }
  }
  
  // === USERS ===
  
  // Get all users
  Future<List<User>> getUsers() async {
    try {
      final file = await _ensureFileExists(_usersFile, '[]');
      final content = await file.readAsString();
      final List<dynamic> jsonData = json.decode(content);
      return jsonData.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error reading users: $e');
      return [];
    }
  }
  
  // Save all users
  Future<void> saveUsers(List<User> users) async {
    try {
      final file = await _ensureFileExists(_usersFile, '[]');
      final content = json.encode(users.map((u) => u.toJson()).toList());
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }
  
  // Add a user
  Future<void> addUser(User user) async {
    try {
      final users = await getUsers();
      users.add(user);
      await saveUsers(users);
    } catch (e) {
      debugPrint('Error adding user: $e');
    }
  }
  
  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      final users = await getUsers();
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      debugPrint('Error getting user by username: $e');
      return null;
    }
  }
}