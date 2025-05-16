import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/local_storage_service.dart';
import '../utils/formatters.dart';
import 'package:uuid/uuid.dart';

class CourseManagementScreen extends StatefulWidget {
  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  
  bool _isLoading = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load courses
      final courses = await _localStorageService.getCourses();
      
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Add or edit a course
  Future<void> _showCourseForm({Course? course}) async {
    final result = await showDialog<Course>(
      context: context,
      builder: (context) => CourseFormDialog(course: course),
    );
    
    if (result != null) {
      try {
        if (course == null) {
          // Add new course
          await _localStorageService.addCourse(result);
        } else {
          // Update existing course
          await _localStorageService.updateCourse(result);
        }
        
        // Reload courses
        _loadCourses();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(course == null ? 'Course added' : 'Course updated'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Error saving course: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Toggle course active status
  Future<void> _toggleCourseStatus(Course course) async {
    try {
      final updatedCourse = course.copyWith(isActive: !course.isActive);
      await _localStorageService.updateCourse(updatedCourse);
      
      // Reload courses
      _loadCourses();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            course.isActive ? 'Course deactivated' : 'Course activated',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error updating course status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating course status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No courses found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add New Course'),
                        onPressed: () => _showCourseForm(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          course.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.description),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  course.getFormattedDuration(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.attach_money, size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  Formatters.formatCurrency(course.price),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: course.isActive ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Actions menu
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showCourseForm(course: course);
                                    break;
                                  case 'toggle':
                                    _toggleCourseStatus(course);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit Course'),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(course.isActive
                                      ? 'Mark as Inactive'
                                      : 'Mark as Active'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showCourseForm(course: course),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add Course',
        onPressed: () => _showCourseForm(),
      ),
    );
  }
}

// Course form dialog
class CourseFormDialog extends StatefulWidget {
  final Course? course;
  
  const CourseFormDialog({
    Key? key,
    this.course,
  }) : super(key: key);

  @override
  _CourseFormDialogState createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _trainerController = TextEditingController();
  final _categoryController = TextEditingController();
  
  bool _isActive = true;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.course != null) {
      // Populate form with course data
      _nameController.text = widget.course!.name;
      _descriptionController.text = widget.course!.description;
      _priceController.text = widget.course!.price.toString();
      _durationController.text = widget.course!.duration.toString();
      _trainerController.text = widget.course!.trainerName ?? '';
      _categoryController.text = widget.course!.category ?? '';
      _isActive = widget.course!.isActive;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _trainerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
  
  // Save form
  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    
    final course = Course(
      id: widget.course?.id ?? Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      duration: int.parse(_durationController.text),
      trainerName: _trainerController.text.trim(),
      category: _categoryController.text.trim(),
      isActive: _isActive,
    );
    
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Course description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Price and duration
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration (days)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Category and trainer
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _trainerController,
                        decoration: InputDecoration(
                          labelText: 'Trainer',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Active status
                CheckboxListTile(
                  title: Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.course == null ? 'Add' : 'Save'),
          onPressed: _saveForm,
        ),
      ],
    );
  }
}