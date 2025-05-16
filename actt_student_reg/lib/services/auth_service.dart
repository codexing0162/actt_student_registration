
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Service to handle user authentication
class AuthService {
  // Key for storing user data in SharedPreferences
  static const String _userKey = 'current_user';
  
  // Get the currently logged in user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) {
      return null;
    }
    
    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      debugPrint('Error parsing user data: $e');
      return null;
    }
  }
  
  // Check if a user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  // Login a user
  Future<User?> login(String username, String password) async {
    // In a real app, this would call an API or check a database
    // For this example, we'll use a simple check with predefined users
    
    // Demo users for testing
    final demoUsers = [
      User(
        id: '1',
        username: 'admin',
        password: 'admin123',
        fullName: 'Admin User',
        email: 'admin@actttraining.com',
        role: AppRole.admin,
      ),
      User(
        id: '2',
        username: 'teacher',
        password: 'teacher123',
        fullName: 'Teacher User',
        email: 'teacher@actttraining.com',
        role: AppRole.teacher,
      ),
      User(
        id: '3',
        username: 'accounting',
        password: 'accounting123',
        fullName: 'Accounting User',
        email: 'accounting@actttraining.com',
        role: AppRole.accounting,
      ),
    ];
    
    // Find user with matching username and password
    final user = demoUsers.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => User(
        id: '',
        username: '',
        password: '',
        fullName: '',
        email: '',
        role: AppRole.teacher,
      ),
    );
    
    // If user not found, return null
    if (user.id.isEmpty) {
      return null;
    }
    
    // Save user to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    
    return user;
  }
  
  // Logout the current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  
  // Register a new user (admin only)
  Future<User?> registerUser(User user) async {
    // In a real app, this would call an API or add to a database
    // For this example, we'll just validate and return the user
    
    // Validate required fields
    if (user.username.isEmpty ||
        user.password.isEmpty ||
        user.fullName.isEmpty ||
        user.email.isEmpty) {
      return null;
    }
    
    // Return the new user
    return user;
  }
  
  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final user = await getCurrentUser();
    
    if (user == null) {
      return false;
    }
    
    // Verify current password
    if (user.password != currentPassword) {
      return false;
    }
    
    // Update password
    final updatedUser = user.copyWith(password: newPassword);
    
    // Save updated user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(updatedUser.toJson()));
    
    return true;
  }
  
  // Update user profile
  Future<bool> updateProfile(String fullName, String email) async {
    final user = await getCurrentUser();
    
    if (user == null) {
      return false;
    }
    
    // Update user data
    final updatedUser = user.copyWith(
      fullName: fullName,
      email: email,
    );
    
    // Save updated user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(updatedUser.toJson()));
    
    return true;
  }
}