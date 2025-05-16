import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';
import '../components/student_card.dart';
import '../screens/student_form.dart';
import '../utils/formatters.dart';

class GraduatedStudentsScreen extends StatefulWidget {
  @override
  _GraduatedStudentsScreenState createState() => _GraduatedStudentsScreenState();
}

class _GraduatedStudentsScreenState extends State<GraduatedStudentsScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  
  bool _isLoading = true;
  List<Student> _graduatedStudents = [];
  String _searchQuery = '';
  String _sortBy = 'completionDate'; // Default sort by completion date
  bool _sortAscending = false; // Default descending (newest graduates first)

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all students
      final students = await _localStorageService.getStudents();
      
      // Filter to only include graduated students
      final graduated = students.where((s) => s.isGraduated).toList();
      
      setState(() {
        _graduatedStudents = graduated;
        _isLoading = false;
      });
      
      // Apply sorting
      _sortStudents();
    } catch (e) {
      debugPrint('Error loading graduated students: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Sort students based on selected criteria
  void _sortStudents() {
    _graduatedStudents.sort((a, b) {
      dynamic valueA;
      dynamic valueB;
      
      // Extract the appropriate field for sorting
      switch (_sortBy) {
        case 'name':
          valueA = a.fullName;
          valueB = b.fullName;
          break;
        case 'courseName':
          valueA = a.courseName;
          valueB = b.courseName;
          break;
        case 'completionDate':
          valueA = a.completionDate;
          valueB = b.completionDate;
          break;
        case 'admissionDate':
          valueA = a.admissionDate;
          valueB = b.admissionDate;
          break;
        default:
          valueA = a.completionDate;
          valueB = b.completionDate;
      }
      
      // Compare the values based on sort direction
      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.compareTo(valueB);
      } else if (valueA is DateTime && valueB is DateTime) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = 0; // Default if types are not comparable
      }
      
      // Reverse if descending order
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {});
  }
  
  // Filter students by search query
  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  // Get filtered students
  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return _graduatedStudents;
    }
    
    final query = _searchQuery.toLowerCase();
    return _graduatedStudents.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.courseName.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduated Students'),
        actions: [
          // Search button
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              showDialog(
                context: context,
                builder: (context) => SearchDialog(
                  initialQuery: _searchQuery,
                  onSearch: _filterStudents,
                ),
              );
            },
          ),
          // Sort options menu
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  // Toggle direction if same field
                  _sortAscending = !_sortAscending;
                } else {
                  // Set new field and reset direction
                  _sortBy = value;
                  _sortAscending = value == 'name'; // Ascending for names, descending for dates
                }
                _sortStudents();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Text('Name'),
              ),
              PopupMenuItem(
                value: 'courseName',
                child: Text('Course'),
              ),
              PopupMenuItem(
                value: 'completionDate',
                child: Text('Completion Date'),
              ),
              PopupMenuItem(
                value: 'admissionDate',
                child: Text('Admission Date'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _graduatedStudents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No graduated students found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'No graduated students match your search criteria.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        
                        return StudentCard(
                          student: student,
                          onTap: () {
                            // Navigate to student details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentFormScreen(
                                  student: student,
                                  onStudentUpdated: (updatedStudent) {
                                    // Refresh the list if student data changes
                                    _loadStudents();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
      // No floating action button since this is just a view screen
    );
  }
}

// Search dialog
class SearchDialog extends StatefulWidget {
  final String initialQuery;
  final Function(String) onSearch;
  
  const SearchDialog({
    Key? key,
    required this.initialQuery,
    required this.onSearch,
  }) : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search Graduated Students'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter name, course, or ID',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) {
          widget.onSearch(value);
          Navigator.of(context).pop();
        },
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Search'),
          onPressed: () {
            widget.onSearch(_controller.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}