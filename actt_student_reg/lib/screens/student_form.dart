import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'package:uuid/uuid.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student; // null for new student
  final Function(Student) onStudentUpdated;
  
  const StudentFormScreen({
    Key? key,
    this.student,
    required this.onStudentUpdated,
  }) : super(key: key);

  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorageService _localStorageService = LocalStorageService();
  late GoogleSheetsService _googleSheetsService;
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Form values
  DateTime _dob = DateTime.now().subtract(Duration(days: 365 * 20)); // Default to 20 years ago
  String _gender = 'Male';
  String _educationLevel = 'High School';
  String _courseName = '';
  String _trainerName = '';
  DateTime _admissionDate = DateTime.now();
  DateTime? _completionDate;
  int _duration = 30; // Default duration in days
  double _amountPaid = 0.0;
  
  bool _isLoading = true;
  bool _isSaving = false;
  List<Course> _availableCourses = [];
  List<String> _availableTrainers = [];

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load available courses
      _availableCourses = await _localStorageService.getCourses();
      
      // If no courses available, add some defaults
      if (_availableCourses.isEmpty) {
        _availableCourses = [
          Course(
            id: '1',
            name: 'Web Development',
            price: 1200.0,
            duration: 90,
            description: 'Learn HTML, CSS, JavaScript and more',
          ),
          Course(
            id: '2',
            name: 'Mobile App Development',
            price: 1500.0,
            duration: 120,
            description: 'Build Android and iOS apps using Flutter',
          ),
          Course(
            id: '3',
            name: 'Data Science',
            price: 2000.0,
            duration: 180,
            description: 'Learn data analysis, visualization and machine learning',
          ),
        ];
        
        // Save default courses
        await _localStorageService.saveCourses(_availableCourses);
      }
      
      // Set default course if available
      if (_availableCourses.isNotEmpty && _courseName.isEmpty) {
        _courseName = _availableCourses[0].name;
        _priceController.text = _availableCourses[0].price.toString();
        _duration = _availableCourses[0].duration;
      }
      
      // Populate trainers (in a real app, you'd load this from storage)
      _availableTrainers = ['John Doe', 'Jane Smith', 'Robert Johnson', 'Mary Williams'];
      if (_trainerName.isEmpty && _availableTrainers.isNotEmpty) {
        _trainerName = _availableTrainers[0];
      }
      
      // If editing an existing student, populate the form
      if (widget.student != null) {
        _fullNameController.text = widget.student!.fullName;
        _dob = widget.student!.dob;
        _gender = widget.student!.gender;
        _postalAddressController.text = widget.student!.postalAddress;
        _phoneController.text = widget.student!.phone;
        _emergencyPhoneController.text = widget.student!.emergencyPhone;
        _educationLevel = widget.student!.educationLevel;
        _courseName = widget.student!.courseName;
        _trainerName = widget.student!.trainerName;
        _admissionDate = widget.student!.admissionDate;
        _completionDate = widget.student!.completionDate;
        _duration = widget.student!.duration;
        _priceController.text = widget.student!.price.toString();
        _amountPaid = widget.student!.amountPaid;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Update price and duration when course changes
  void _updateCourseDetails(String courseName) {
    final course = _availableCourses.firstWhere(
      (c) => c.name == courseName,
      orElse: () => Course(
        id: '0',
        name: courseName,
        price: 0.0,
        duration: 30,
        description: '',
      ),
    );
    
    setState(() {
      _courseName = courseName;
      _priceController.text = course.price.toString();
      _duration = course.duration;
    });
  }
  
  // Save student data
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Create or update student object
      final price = double.parse(_priceController.text);
      final remainingPrice = price - _amountPaid;
      
      final student = Student(
        id: widget.student?.id ?? Uuid().v4(),
        fullName: _fullNameController.text,
        dob: _dob,
        gender: _gender,
        postalAddress: _postalAddressController.text,
        phone: _phoneController.text,
        emergencyPhone: _emergencyPhoneController.text,
        educationLevel: _educationLevel,
        courseName: _courseName,
        trainerName: _trainerName,
        admissionDate: _admissionDate,
        completionDate: _completionDate,
        duration: _duration,
        price: price,
        amountPaid: _amountPaid,
        remainingPrice: remainingPrice,
      );
      
      bool success = false;
      
      // Try to save to Google Sheets first
      if (widget.student == null) {
        // New student
        success = await _googleSheetsService.addStudent(student);
      } else {
        // Existing student
        success = await _googleSheetsService.updateStudent(student);
      }
      
      // Save locally regardless of online success
      if (widget.student == null) {
        await _localStorageService.addStudent(student);
      } else {
        await _localStorageService.updateStudent(student);
      }
      
      // Notify parent and pop
      widget.onStudentUpdated(student);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Student saved successfully!'
                : 'Student saved locally and will be synced when online.',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      debugPrint('Error saving student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  // Show date picker for selecting dates
  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
        actions: [
          if (widget.student != null)
            IconButton(
              icon: Icon(Icons.check_circle),
              tooltip: 'Mark as Completed',
              onPressed: () {
                // Show completion confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Mark as Completed'),
                    content: Text(
                      'Do you want to mark this student as having completed the course?'
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        child: Text('Mark Complete'),
                        onPressed: () {
                          setState(() {
                            _completionDate = DateTime.now();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.only(bottom: 100), // Add bottom padding to avoid overflow

                  children: [
                    // Personal Information Section
                    _buildSectionHeader('Personal Information'),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the student\'s name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Date of Birth Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(
                              context,
                              _dob,
                              (date) => setState(() => _dob = date),
                            ),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Formatters.formatDate(_dob)),
                                  Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Male', 'Female', 'Other'].map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _gender = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _postalAddressController,
                      decoration: InputDecoration(
                        labelText: 'Postal Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    // Phone Numbers Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _emergencyPhoneController,
                            decoration: InputDecoration(
                              labelText: 'Emergency Phone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _educationLevel,
                      decoration: InputDecoration(
                        labelText: 'Education Level',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Primary School',
                        'Middle School',
                        'High School',
                        'College',
                        'Bachelor\'s Degree',
                        'Master\'s Degree',
                        'Doctorate',
                        'Other',
                      ].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _educationLevel = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Course Information Section
                    _buildSectionHeader('Course Information'),
                    DropdownButtonFormField<String>(
                      value: _courseName,
                      decoration: InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableCourses.map((course) {
                        return DropdownMenuItem(
                          value: course.name,
                          child: Text(course.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateCourseDetails(value);
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _trainerName,
                      decoration: InputDecoration(
                        labelText: 'Trainer',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableTrainers.map((trainer) {
                        return DropdownMenuItem(
                          value: trainer,
                          child: Text(trainer),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _trainerName = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    // Admission Date Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(
                              context,
                              _admissionDate,
                              (date) => setState(() => _admissionDate = date),
                            ),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Admission Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Formatters.formatDate(_admissionDate)),
                                  Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _completionDate == null
                              ? TextFormField(
                                  initialValue: _duration.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Duration (days)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        _duration = int.tryParse(value) ?? _duration;
                                      });
                                    }
                                  },
                                )
                              : InkWell(
                                  onTap: () => _selectDate(
                                    context,
                                    _completionDate!,
                                    (date) => setState(() => _completionDate = date),
                                  ),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Completion Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(Formatters.formatDate(_completionDate!)),
                                        Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Payment Information Section
                    _buildSectionHeader('Payment Information'),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Course Price',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the course price';
                        }
                        try {
                          final price = double.parse(value);
                          if (price < 0) {
                            return 'Price cannot be negative';
                          }
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Show payment fields only when editing existing student
                    if (widget.student != null) ...[
                      TextFormField(
                        initialValue: _amountPaid.toString(),
                        decoration: InputDecoration(
                          labelText: 'Amount Paid',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _amountPaid = double.tryParse(value) ?? _amountPaid;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount paid';
                          }
                          try {
                            final amount = double.parse(value);
                            if (amount < 0) {
                              return 'Amount cannot be negative';
                            }
                            if (amount > double.parse(_priceController.text)) {
                              return 'Amount cannot exceed the course price';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      // Payment status indicator
                      LinearProgressIndicator(
                        value: _amountPaid / (double.tryParse(_priceController.text) ?? 1),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _amountPaid >= (double.tryParse(_priceController.text) ?? 0)
                              ? Colors.green
                              : Colors.blue,
                        ),
                        minHeight: 10,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Payment Progress: ${((_amountPaid / (double.tryParse(_priceController.text) ?? 1)) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _amountPaid >= (double.tryParse(_priceController.text) ?? 0)
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paid: \$${_amountPaid.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            'Remaining: \$${((double.tryParse(_priceController.text) ?? 0) - _amountPaid).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _amountPaid >= (double.tryParse(_priceController.text) ?? 0)
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 32),
                    
                    // Save Button
                    ElevatedButton(
                      child: _isSaving
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              widget.student == null ? 'Add Student' : 'Save Changes',
                              style: TextStyle(fontSize: 16),
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isSaving ? null : _saveStudent,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }
}