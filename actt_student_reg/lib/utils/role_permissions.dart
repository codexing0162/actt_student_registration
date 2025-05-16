import '../models/user.dart';

// Define role permissions for the app
class RolePermissions {
  // Check if role can access student management
  static bool canAccessStudents(AppRole role) {
    // All roles can access student list and view student details
    return true;
  }
  
  // Check if role can modify students
  static bool canModifyStudents(AppRole role) {
    // Admin and teacher roles can add/edit students
    return role == AppRole.admin || role == AppRole.teacher;
  }
  
  // Check if role can delete students
  static bool canDeleteStudents(AppRole role) {
    // Only admin can delete students
    return role == AppRole.admin;
  }
  
  // Check if role can access payment features
  static bool canAccessPayments(AppRole role) {
    // Admin and accounting roles can access payment tracking
    return role == AppRole.admin || role == AppRole.accounting;
  }
  
  // Check if role can record payments
  static bool canRecordPayments(AppRole role) {
    // Admin and accounting roles can record payments
    return role == AppRole.admin || role == AppRole.accounting;
  }
  
  // Check if role can delete payments
  static bool canDeletePayments(AppRole role) {
    // Only admin can delete payments
    return role == AppRole.admin;
  }
  
  // Check if role can access statistics dashboard
  static bool canAccessStatistics(AppRole role) {
    // Admin and teacher roles can access statistics
    return role == AppRole.admin || role == AppRole.teacher;
  }
  
  // Check if role can access financial reports
  static bool canAccessFinancialReports(AppRole role) {
    // Admin and accounting roles can access financial reports
    return role == AppRole.admin || role == AppRole.accounting;
  }
  
  // Check if role can manage courses
  static bool canManageCourses(AppRole role) {
    // Only admin can manage courses
    return role == AppRole.admin;
  }
  
  // Check if role can manage users
  static bool canManageUsers(AppRole role) {
    // Only admin can manage users
    return role == AppRole.admin;
  }
  
  // Check if role can change app settings
  static bool canChangeSettings(AppRole role) {
    // Only admin can change app settings
    return role == AppRole.admin;
  }
  
  // Check if role can mark students as graduated
  static bool canGraduateStudents(AppRole role) {
    // Admin and teacher roles can mark students as graduated
    return role == AppRole.admin || role == AppRole.teacher;
  }
  
  // Get the list of features accessible by a role
  static List<String> getAccessibleFeatures(AppRole role) {
    final features = <String>[];
    
    // Common features for all roles
    features.add('View Students');
    features.add('View Graduated Students');
    
    // Role-specific features
    switch (role) {
      case AppRole.admin:
        // Admin has access to all features
        features.add('Add/Edit Students');
        features.add('Delete Students');
        features.add('Payment Tracking');
        features.add('Record Payments');
        features.add('Delete Payments');
        features.add('Statistics Dashboard');
        features.add('Financial Reports');
        features.add('Course Management');
        features.add('User Management');
        features.add('App Settings');
        features.add('Mark Students as Graduated');
        break;
        
      case AppRole.teacher:
        // Teacher role features
        features.add('Add/Edit Students');
        features.add('Statistics Dashboard');
        features.add('Mark Students as Graduated');
        break;
        
      case AppRole.accounting:
        // Accounting role features
        features.add('Payment Tracking');
        features.add('Record Payments');
        features.add('Financial Reports');
        break;
    }
    
    return features;
  }
  
  // Get a description of the role's responsibilities
  static String getRoleDescription(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Full access to all features, including student management, '
               'financial tracking, course management, and user administration.';
      case AppRole.teacher:
        return 'Manage student information, view statistics, and mark students as graduated. '
               'Cannot access financial features or administrative settings.';
      case AppRole.accounting:
        return 'Track and record payments, view financial reports. '
               'Cannot modify student course information or access administrative settings.';
      default:
        return 'Basic access to student information.';
    }
  }
}