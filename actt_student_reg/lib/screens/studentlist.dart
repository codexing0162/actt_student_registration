import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:actt_student_reg/screens/home.dart';
import 'package:actt_student_reg/component/action.dart';
import 'package:actt_student_reg/component/drawer.dart';
import 'package:actt_student_reg/screens/studentdetail.dart';

final String _studentsFilePath = 'lib/localstorage/students.json';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  bool _fetchFromLocal = true; // Toggle between local and online data
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> data;
      if (_fetchFromLocal) {
        data = await _fetchLocalData();
      } else {
        data = await _fetchGoogleSheetData();
      }

      setState(() {
        _students = data;
        _filteredStudents = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLocalData() async {
    try {
      final file = File(_studentsFilePath);

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

  Future<List<Map<String, dynamic>>> _fetchGoogleSheetData() async {
    try {
      // Replace with your Google Sheets API URL
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbySt_PdLxKtje6gW5YlP2IdUOgKJpd3wl6HalvyEulZ_ft52-QKoRf3bYRth7cD64d6/exec',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log the response for debugging
        print('Google Sheets API Response: $data');

        // Ensure 'data' is a list
        if (data is List<dynamic>) {
          final List<dynamic> rows = data;

          // Convert rows to a list of maps, skipping invalid rows
          return rows
              .map((row) {
                if (row is Map<String, dynamic>) {
                  return {
                    'Student': row['Student'] ?? '',
                    'fullName': row['fullName'] ?? '',
                    'dob': row['dob'] ?? '',
                    'gender': row['gender'] ?? '',
                    'postalAddress': row['postalAddress'] ?? '',
                    'phone': row['phone'] ?? '',
                    'emergencyPhone': row['emergencyPhone'] ?? '',
                    'educationLevel': row['educationLevel'] ?? '',
                    'courseName': row['courseName'] ?? '',
                    'trainerName': row['trainerName'] ?? '',
                    'admissionDate': row['admissionDate'] ?? '',
                    'completionDate': row['completionDate'] ?? '',
                    'duration': row['duration'] ?? '',
                    'price': row['price'] ?? '',
                    'amountPaid': row['amountPaid'] ?? '',
                    'remainingPrice': row['remainingPrice'] ?? '',
                  };
                } else {
                  // Skip invalid rows
                  return null;
                }
              })
              .where((row) => row != null)
              .cast<Map<String, dynamic>>()
              .toList();
        } else {
          throw Exception('Invalid data format from Google Sheets');
        }
      } else {
        throw Exception('Failed to fetch data from Google Sheets');
      }
    } catch (e) {
      print('Error fetching Google Sheets data: $e');
      throw Exception('Error fetching Google Sheets data: $e');
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents =
          _students
              .where(
                (student) =>
                    (student['Student'] ?? '').toLowerCase().contains(query) ||
                    (student['fullName'] ?? '').toLowerCase().contains(query) ||
                    (student['courseName'] ?? '')
                        .toLowerCase()
                        .contains(query)(student['trainerName'] ?? '')
                        .toLowerCase()
                        .contains(query) ||
                    (student['phone'] ?? '').toLowerCase().contains(query) ||
                    (student['dob'] ?? '').toLowerCase().contains(query) ||
                    (student['postalAddress'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['emergencyPhone'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['educationLevel'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['admissionDate'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['completionDate'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['duration'] ?? '').toLowerCase().contains(query) ||
                    (student['price'] ?? '').toLowerCase().contains(query) ||
                    (student['amountPaid'] ?? '').toLowerCase().contains(
                      query,
                    ) ||
                    (student['remainingPrice'] ?? '').toLowerCase().contains(
                      query,
                    ),
              )
              .toList();
    });
  }

  void _toggleFetchSource() {
    setState(() {
      _fetchFromLocal = !_fetchFromLocal;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [ActionSyncButton()],
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        backgroundColor: Colors.blueGrey,
        elevation: 10,
        child: Icon(Icons.refresh),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fetch from:'),
                ElevatedButton(
                  onPressed: _toggleFetchSource,
                  child: Text(
                    _fetchFromLocal ? 'Local Storage' : 'Google Sheets',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredStudents.isEmpty
                    ? const Center(
                      child: Text('No students found Try Fetch Online'),
                    )
                    : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return GestureDetector(
                          onTap: () {
                            // Handle student selection
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        StudentDetailPage(student: student),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(student['fullName'] ?? 'Unknown'),
                              subtitle: Text(
                                'Course: ${student['courseName'] ?? 'N/A'}',
                              ),
                              trailing: Text(
                                'Price: ${student['price'] ?? 'N/A'}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  pushAndDeleteStudentData() {}
}
