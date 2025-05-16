import 'package:flutter/foundation.dart';

class Student {
  final String id;
  final String fullName;
  final DateTime dob;
  final String gender;
  final String postalAddress;
  final String phone;
  final String emergencyPhone;
  final String educationLevel;
  final String courseName;
  final String trainerName;
  final DateTime admissionDate;
  final DateTime? completionDate; // Nullable as might not be completed
  final int duration; // Duration in days
  final double price;
  final double amountPaid;
  final double remainingPrice;

  // Constructor with required fields
  Student({
    required this.id,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.postalAddress,
    required this.phone,
    required this.emergencyPhone,
    required this.educationLevel,
    required this.courseName,
    required this.trainerName,
    required this.admissionDate,
    this.completionDate,
    required this.duration,
    required this.price,
    required this.amountPaid,
    required this.remainingPrice,
  });

  // Create Student from JSON data (for local storage and API responses)
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      dob: DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String,
      postalAddress: json['postalAddress'] as String,
      phone: json['phone'] as String,
      emergencyPhone: json['emergencyPhone'] as String,
      educationLevel: json['educationLevel'] as String,
      courseName: json['courseName'] as String,
      trainerName: json['trainerName'] as String,
      admissionDate: DateTime.parse(json['admissionDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      duration: json['duration'] as int,
      price: (json['price'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      remainingPrice: (json['remainingPrice'] as num).toDouble(),
    );
  }

  // Convert Student to JSON for storage and API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'postalAddress': postalAddress,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'educationLevel': educationLevel,
      'courseName': courseName,
      'trainerName': trainerName,
      'admissionDate': admissionDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'duration': duration,
      'price': price,
      'amountPaid': amountPaid,
      'remainingPrice': remainingPrice,
    };
  }

  // Create a copy of Student with updated fields
  Student copyWith({
    String? id,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? postalAddress,
    String? phone,
    String? emergencyPhone,
    String? educationLevel,
    String? courseName,
    String? trainerName,
    DateTime? admissionDate,
    DateTime? completionDate,
    int? duration,
    double? price,
    double? amountPaid,
    double? remainingPrice,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      postalAddress: postalAddress ?? this.postalAddress,
      phone: phone ?? this.phone,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      educationLevel: educationLevel ?? this.educationLevel,
      courseName: courseName ?? this.courseName,
      trainerName: trainerName ?? this.trainerName,
      admissionDate: admissionDate ?? this.admissionDate,
      completionDate: completionDate ?? this.completionDate,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingPrice: remainingPrice ?? this.remainingPrice,
    );
  }

  // Check if student has graduated based on completion date
  bool get isGraduated => completionDate != null && completionDate!.isBefore(DateTime.now());

  // Calculate expected completion date based on admission date and duration
  DateTime get expectedCompletionDate => 
      admissionDate.add(Duration(days: duration));

  // Calculate payment progress percentage
  double get paymentProgress => price > 0 ? (amountPaid / price) * 100 : 0;

  // Has student fully paid?
  bool get isFullyPaid => remainingPrice <= 0;

  @override
  String toString() => 'Student(id: $id, name: $fullName, course: $courseName)';
}