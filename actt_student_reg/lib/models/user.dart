import 'package:flutter/foundation.dart';

// Enum for user roles
enum AppRole {
  admin,
  teacher,
  accounting,
}

// User model class
class User {
  final String id;
  final String username;
  final String password; // In a real app, this would be hashed
  final String fullName;
  final String email;
  final AppRole role;
  final String? phoneNumber;
  final DateTime? lastLogin;
  final bool isActive;

  // Constructor with required fields
  User({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.lastLogin,
    this.isActive = true,
  });

  // Create User from JSON data (for local storage and API responses)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: _roleFromString(json['role'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // Convert User to JSON for storage and API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'role': _roleToString(role),
      'phoneNumber': phoneNumber,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? fullName,
    String? email,
    AppRole? role,
    String? phoneNumber,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get the role as a human-readable string
  String get roleDisplayName {
    switch (role) {
      case AppRole.admin:
        return 'Administrator';
      case AppRole.teacher:
        return 'Teacher';
      case AppRole.accounting:
        return 'Accounting/Sales';
    }
  }

  // Get initials for avatar
  String get initials {
    if (fullName.isEmpty) return '';
    
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
    } else {
      return fullName.substring(0, 1);
    }
  }

  // Convert role enum to string
  static String _roleToString(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'admin';
      case AppRole.teacher:
        return 'teacher';
      case AppRole.accounting:
        return 'accounting';
    }
  }

  // Convert string to role enum
  static AppRole _roleFromString(String roleStr) {
    switch (roleStr) {
      case 'admin':
        return AppRole.admin;
      case 'teacher':
        return AppRole.teacher;
      case 'accounting':
        return AppRole.accounting;
      default:
        return AppRole.teacher; // Default to teacher if unknown
    }
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: $roleDisplayName)';
}