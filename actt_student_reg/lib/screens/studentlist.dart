import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGoogleSheetData();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _fetchGoogleSheetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycby2HTo4nmtn0yGKvAb3xlF9NNJFQWFFOxeT_o9lrM4tb5riN4_5UYjVRiOBmRk7XlzE/exec',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List<dynamic>) {
          final List<Map<String, dynamic>> rows =
              data
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (row) => {
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
                    },
                  )
                  .toList();

          setState(() {
            _students = rows;
            _filteredStudents = rows;
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid data format from Google Sheets');
        }
      } else {
        throw Exception('Failed to fetch data from Google Sheets');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents =
          _students.where((student) {
            return (student['Student'] ?? '').toLowerCase().contains(query) ||
                (student['fullName'] ?? '').toLowerCase().contains(query) ||
                (student['courseName'] ?? '').toLowerCase().contains(query) ||
                (student['trainerName'] ?? '').toLowerCase().contains(query) ||
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
                (student['amountPaid'] ?? '').toLowerCase().contains(query) ||
                (student['remainingPrice'] ?? '').toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
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
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredStudents.isEmpty
                    ? const Center(child: Text('No students found.'))
                    : RefreshIndicator(
                      onRefresh: _fetchGoogleSheetData,
                      child: ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return GestureDetector(
                            onTap: () {
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _fetchGoogleSheetData(); // Refresh data when FAB is pressed
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({super.key, required this.student});

  Widget _buildInfoTile(String label, dynamic value, {IconData? icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value != null ? value.toString() : '-',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student['fullName'] ?? 'Student Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blueGrey[100],
                child: Text(
                  ((student['fullName'] != null &&
                          (student['fullName'] as String).isNotEmpty)
                      ? (student['fullName'] as String)[0].toUpperCase()
                      : 'S'),
                  style: const TextStyle(fontSize: 40, color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                student['fullName'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                student['courseName'] ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const Divider(height: 32, thickness: 1.2),
              _buildInfoTile(
                'Student ID',
                student['Student'],
                icon: Icons.badge,
              ),
              _buildInfoTile('Date of Birth', student['dob'], icon: Icons.cake),
              _buildInfoTile('Gender', student['gender'], icon: Icons.person),
              _buildInfoTile(
                'Postal Address',
                student['postalAddress'],
                icon: Icons.home,
              ),
              _buildInfoTile('Phone', student['phone'], icon: Icons.phone),
              _buildInfoTile(
                'Emergency Phone',
                student['emergencyPhone'],
                icon: Icons.phone_in_talk,
              ),
              _buildInfoTile(
                'Education Level',
                student['educationLevel'],
                icon: Icons.school,
              ),
              _buildInfoTile(
                'Trainer Name',
                student['trainerName'],
                icon: Icons.person_outline,
              ),
              _buildInfoTile(
                'Admission Date',
                student['admissionDate'],
                icon: Icons.calendar_today,
              ),
              _buildInfoTile(
                'Completion Date',
                student['completionDate'],
                icon: Icons.event_available,
              ),
              _buildInfoTile(
                'Duration',
                student['duration'],
                icon: Icons.timer,
              ),
              _buildInfoTile(
                'Course Price',
                student['price'],
                icon: Icons.attach_money,
              ),
              _buildInfoTile(
                'Amount Paid',
                student['amountPaid'],
                icon: Icons.payments,
              ),
              _buildInfoTile(
                'Remaining Price',
                student['remainingPrice'],
                icon: Icons.money_off,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
