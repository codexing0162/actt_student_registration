import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../components/student_card.dart';
import '../utils/constants.dart';
import '../screens/student_form.dart';
import '../components/datasyc_manager.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  late GoogleSheetsService _googleSheetsService;
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load from Google Sheets first, fall back to local if offline
      final students = await _googleSheetsService.fetchStudents();
      
      // Save fetched students locally
      await _localStorageService.saveStudents(students);
      
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading students: $e');
      
      // If online fetch fails, load from local storage
      final students = await _localStorageService.getStudents();
      
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
      
      // Show offline notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Working offline. Changes will be synced when online.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          return student.fullName.toLowerCase().contains(query.toLowerCase()) ||
              student.courseName.toLowerCase().contains(query.toLowerCase()) ||
              student.id.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or course...',
                  border: InputBorder.none,
                ),
                onChanged: _filterStudents,
              )
            : Text('Student List'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterStudents('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              // Show sync dialog
              showDialog(
                context: context,
                builder: (context) => DataSyncManager(
                  onSyncComplete: () {
                    _loadStudents();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredStudents.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No students found. Add your first student!'
                        : 'No students match your search criteria.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return StudentCard(
                        student: student,
                        onTap: () {
                          // Navigate to student details/edit screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentFormScreen(
                                student: student,
                                onStudentUpdated: (updatedStudent) {
                                  // Update the student list after editing
                                  setState(() {
                                    final index = _students.indexWhere(
                                        (s) => s.id == updatedStudent.id);
                                    if (index >= 0) {
                                      _students[index] = updatedStudent;
                                      _filterStudents(_searchQuery); // Re-filter
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to add student screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentFormScreen(
                onStudentUpdated: (newStudent) {
                  // Add the new student to the list
                  setState(() {
                    _students.add(newStudent);
                    _filterStudents(_searchQuery); // Re-filter
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}