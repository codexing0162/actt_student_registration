import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Utility class for formatting various data types
class Formatters {
  // Currency formatter
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }
  
  // Date formatter (standard format: MMM dd, yyyy)
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Short date formatter (MM/dd/yyyy)
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }
  
  // Time formatter (hh:mm a)
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  // Date and time formatter
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
  
  // Format phone number: (XXX) XXX-XXXX
  static String formatPhone(String phone) {
    if (phone.isEmpty) return '';
    
    // Clean the phone number (remove non-digits)
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Check if we have enough digits
    if (cleaned.length < 10) return phone;
    
    // Format US phone number (XXX) XXX-XXXX
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6, 10)}';
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    return NumberFormat.percentPattern().format(value / 100);
  }
  
  // Format number with commas for thousands
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
  
  // Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    
    // Adjust age if birthday hasn't occurred yet this year
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  // Format days remaining
  static String formatDaysRemaining(int days) {
    if (days <= 0) {
      return 'Expired';
    } else if (days == 1) {
      return '1 day left';
    } else {
      return '$days days left';
    }
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  // Format time ago (for timestamps)
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}