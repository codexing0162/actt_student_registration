import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _postalAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _educationLevelController =
      TextEditingController();
  final TextEditingController _trainerNameController = TextEditingController();
  final TextEditingController _admissionDateController =
      TextEditingController();
  final TextEditingController _completionDateController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _remainingPriceController =
      TextEditingController();

  String? _gender;
  String? _selectedCourse;
  List<Map<String, dynamic>> _courseDetails = [];
  List<String> _courseNames = [];

  // Define file paths for courses and students data
  final String _coursesFilePath = 'lib/localstorage/course.json';
  final String _studentsFilePath = 'lib/localstorage/students.json';

  @override
  void initState() {
    super.initState();
    _loadCourseNames();
  }

  Future<void> _loadCourseNames() async {
    try {
      final file = File(_coursesFilePath);

      if (!(await file.exists())) {
        // Create the file if it doesn't exist
        await file.writeAsString(jsonEncode([]));
      }

      final contents = await file.readAsString();
      final List<dynamic> responseData =
          contents.isNotEmpty ? jsonDecode(contents) : [];
      setState(() {
        _courseNames =
            responseData
                .map((course) => course['courseName'] as String)
                .toList();
        _courseDetails = List<Map<String, dynamic>>.from(responseData);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading courses: $e')));
    }
  }

  Future<void> _saveDataLocally() async {
    final data = {
      'Student': _studentIdController.text,
      'fullName': _fullNameController.text,
      'dob': _dobController.text,
      'gender': _gender,
      'postalAddress': _postalAddressController.text,
      'phone': _phoneController.text,
      'emergencyPhone': _emergencyPhoneController.text,
      'educationLevel': _educationLevelController.text,
      'courseName': _selectedCourse,
      'trainerName': _trainerNameController.text,
      'admissionDate': _admissionDateController.text,
      'completionDate': _completionDateController.text,
      'duration': _durationController.text,
      'price': _priceController.text,
      'amountPaid': _amountPaidController.text,
      'remainingPrice': _remainingPriceController.text,
    };

    try {
      final file = File(_studentsFilePath);

      if (!(await file.exists())) {
        // Create the file if it doesn't exist
        await file.writeAsString(jsonEncode([]));
      }

      List<dynamic> existingData = [];
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        existingData = jsonDecode(contents);
      }

      existingData.add(data);
      await file.writeAsString(jsonEncode(existingData));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data saved locally!')));

      // Clear the form after saving
      clearForm();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.black,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField('Student ID', controller: _studentIdController),
              _buildTextField('Full Name', controller: _fullNameController),
              _buildTextField(
                'Date of Birth',
                isDate: true,
                controller: _dobController,
              ),
              _buildGenderDropdown(),
              _buildTextField(
                'Postal Address (Optional)',
                controller: _postalAddressController,
              ),
              _buildTextField('Phone Number', controller: _phoneController),
              _buildTextField(
                'Emergency Phone Number',
                controller: _emergencyPhoneController,
              ),
              _buildTextField(
                'Education Level (Optional)',
                controller: _educationLevelController,
              ),
              _buildCourseDropdown(),
              _buildTextField(
                'Trainer Name',
                controller: _trainerNameController,
              ),
              _buildTextField(
                'Date of Admission',
                isDate: true,
                controller: _admissionDateController,
              ),
              _buildTextField(
                'Date of Completion',
                isDate: true,
                controller: _completionDateController,
              ),
              _buildTextField(
                'Duration',
                controller: _durationController,
                readOnly: true,
              ),
              _buildTextField(
                'Price',
                controller: _priceController,
                readOnly: true,
              ),
              _buildTextField(
                'Amount Paid',
                controller: _amountPaidController,
                onChanged: (value) {
                  final price = double.tryParse(_priceController.text) ?? 0.0;
                  final amountPaid = double.tryParse(value) ?? 0.0;
                  final remainingPrice = price - amountPaid;
                  _remainingPriceController.text = remainingPrice.toString();
                },
              ),
              _buildTextField(
                'Remaining Price',
                controller: _remainingPriceController,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveDataLocally,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: const Text('SUBMIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    bool isDate = false,
    TextEditingController? controller,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        readOnly: isDate || readOnly,
        onChanged: onChanged,
        onTap:
            isDate
                ? () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    controller?.text =
                        '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
                  }
                }
                : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _gender,
        items:
            ['Male', 'Female', 'Others']
                .map(
                  (gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _gender = value;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCourse,
        items:
            _courseNames
                .map(
                  (course) =>
                      DropdownMenuItem(value: course, child: Text(course)),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCourse = value;

            // Auto-fill duration and price based on selected course
            final selectedCourseDetails = _courseDetails.firstWhere(
              (course) => course['courseName'] == value,
            );
            _durationController.text = selectedCourseDetails['duration'];
            _priceController.text = selectedCourseDetails['price'].toString();
          });
        },
        decoration: const InputDecoration(
          labelText: 'Course Name',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void clearForm() {
    _studentIdController.clear();
    _fullNameController.clear();
    _dobController.clear();
    _postalAddressController.clear();
    _phoneController.clear();
    _emergencyPhoneController.clear();
    _educationLevelController.clear();
    _trainerNameController.clear();
    _admissionDateController.clear();
    _completionDateController.clear();
    _durationController.clear();
    _priceController.clear();
    _amountPaidController.clear();
    _remainingPriceController.clear();
    setState(() {
      _gender = null;
      _selectedCourse = null;
    });
  }
}
