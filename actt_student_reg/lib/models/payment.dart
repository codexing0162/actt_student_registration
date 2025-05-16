import 'package:flutter/foundation.dart';

// Payment model class
class Payment {
  final String id;
  final String studentId;
  final double amount;
  final String description;
  final DateTime date;
  final String? receiptNumber;
  final String? paymentMethod;

  // Constructor with required fields
  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.description,
    required this.date,
    this.receiptNumber,
    this.paymentMethod,
  });

  // Create Payment from JSON data (for local storage and API responses)
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      receiptNumber: json['receiptNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  // Convert Payment to JSON for storage and API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'receiptNumber': receiptNumber,
      'paymentMethod': paymentMethod,
    };
  }

  // Create a copy of Payment with updated fields
  Payment copyWith({
    String? id,
    String? studentId,
    double? amount,
    String? description,
    DateTime? date,
    String? receiptNumber,
    String? paymentMethod,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() => 'Payment(id: $id, studentId: $studentId, amount: $amount)';
}