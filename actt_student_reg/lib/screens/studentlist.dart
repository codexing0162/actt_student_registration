import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:actt_student_reg/screens/home.dart';

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

  Future<List<Map<String, dynamic>>> _fetchGoogleSheetData() async {
    try {
      // Replace with your Google Sheets API URL
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycby2HTo4nmtn0yGKvAb3xlF9NNJFQWFFOxeT_o9lrM4tb5riN4_5UYjVRiOBmRk7XlzE/exec',
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Image.asset('lib/images/acttlogo.png'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Handle home tap
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const homepage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Student List'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentList()),
                );
                // Handle student list tap
              },
            ),
          ],
        ),
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
}

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Details for ${student['fullName'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Student ID:', student['Student']),
                _buildDetailRow('Full Name:', student['fullName']),
                _buildDetailRow('Date of Birth:', student['dob']),
                _buildDetailRow('Course:', student['courseName']),
                _buildDetailRow('Trainer:', student['trainerName']),
                _buildDetailRow('Phone:', student['phone']),
                _buildDetailRow('Emergency Phone:', student['emergencyPhone']),
                _buildDetailRow('Postal Address:', student['postalAddress']),
                _buildDetailRow('Education Level:', student['educationLevel']),
                _buildDetailRow('Admission Date:', student['admissionDate']),
                _buildDetailRow('Completion Date:', student['completionDate']),
                _buildDetailRow('Duration:', student['duration']),
                _buildDetailRow('Amount Paid:', student['amountPaid']),
                _buildDetailRow(
                  'Remaining Price:',
                  student['remainingPrice'],
                  isHighlighted: true,
                ),
                _buildDetailRow('Price:', student['price']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    dynamic value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ??
                  'N/A', // Convert value to string and handle null
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.red : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
