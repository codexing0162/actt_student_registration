import 'package:flutter/foundation.dart';

// Course model class
class Course {
  final String id;
  final String name;
  final double price;
  final int duration; // Duration in days
  final String description;
  final String? trainerName;
  final String? category;
  final bool isActive;

  // Constructor with required fields
  Course({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    this.trainerName,
    this.category,
    this.isActive = true,
  });

  // Create Course from JSON data (for local storage and API responses)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      description: json['description'] as String,
      trainerName: json['trainerName'] as String?,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // Convert Course to JSON for storage and API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'trainerName': trainerName,
      'category': category,
      'isActive': isActive,
    };
  }

  // Create a copy of Course with updated fields
  Course copyWith({
    String? id,
    String? name,
    double? price,
    int? duration,
    String? description,
    String? trainerName,
    String? category,
    bool? isActive,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      trainerName: trainerName ?? this.trainerName,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get expected completion date based on duration
  DateTime getExpectedCompletionDate(DateTime startDate) {
    return startDate.add(Duration(days: duration));
  }

  // Get a formatted duration string (e.g. "3 months", "2 weeks")
  String getFormattedDuration() {
    if (duration < 7) {
      return '$duration days';
    } else if (duration < 30) {
      final weeks = (duration / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (duration < 365) {
      final months = (duration / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (duration / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
  }

  @override
  String toString() => 'Course(id: $id, name: $name, duration: $duration days)';
}