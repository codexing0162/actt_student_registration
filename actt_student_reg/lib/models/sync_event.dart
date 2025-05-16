import 'package:flutter/foundation.dart';

// SyncEvent model class to track pending changes for syncing
class SyncEvent {
  final String id;
  final String type; // ADD, UPDATE, DELETE, PAYMENT
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isPending;
  final String? error;

  // Constructor with required fields
  SyncEvent({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isPending = true,
    this.error,
  });

  // Create SyncEvent from JSON data (for local storage)
  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPending: json['isPending'] as bool? ?? true,
      error: json['error'] as String?,
    );
  }

  // Convert SyncEvent to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isPending': isPending,
      'error': error,
    };
  }

  // Create a copy of SyncEvent with updated fields
  SyncEvent copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isPending,
    String? error,
  }) {
    return SyncEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isPending: isPending ?? this.isPending,
      error: error ?? this.error,
    );
  }

  // Get a descriptive message for the sync event
  String get description {
    switch (type) {
      case 'ADD':
        return 'Add ${data['fullName'] ?? 'student'}';
      case 'UPDATE':
        return 'Update ${data['fullName'] ?? 'student'}';
      case 'DELETE':
        return 'Delete ${data['fullName'] ?? 'student'}';
      case 'PAYMENT':
        return 'Payment of \$${data['amount']} for student ID ${data['studentId']}';
      default:
        return type;
    }
  }

  @override
  String toString() => 'SyncEvent(id: $id, type: $type, isPending: $isPending)';
}