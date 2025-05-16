import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/course.dart';
import '../utils/formatters.dart';

// Service to calculate various statistics for the app
class StatisticsService {
  // Calculate distribution of students by course
  Map<String, int> calculateStudentsByCourse(List<Student> students) {
    final result = <String, int>{};
    
    for (final student in students) {
      final course = student.courseName;
      if (result.containsKey(course)) {
        result[course] = result[course]! + 1;
      } else {
        result[course] = 1;
      }
    }
    
    return result;
  }
  
  // Calculate distribution of revenue by course
  Map<String, double> calculateRevenueByCourse(List<Student> students) {
    final result = <String, double>{};
    
    for (final student in students) {
      final course = student.courseName;
      final revenue = student.amountPaid;
      
      if (result.containsKey(course)) {
        result[course] = result[course]! + revenue;
      } else {
        result[course] = revenue;
      }
    }
    
    return result;
  }
  
  // Calculate monthly enrollment trends (last 12 months)
  List<Map<String, dynamic>> calculateMonthlyEnrollment(List<Student> students) {
    // Initialize result with the last 12 months
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Create empty data for the last 12 months
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = Formatters.formatDate(month).substring(0, 3); // Get short month name
      
      result.add({
        'month': monthName,
        'count': 0,
      });
    }
    
    // Count students by admission month
    for (final student in students) {
      final admissionDate = student.admissionDate;
      
      // Only count students from the last 12 months
      if (admissionDate.isAfter(DateTime(now.year, now.month - 11, 1))) {
        // Calculate month index relative to current month
        final monthDiff = (now.year - admissionDate.year) * 12 + now.month - admissionDate.month;
        final monthIndex = 11 - monthDiff;
        
        if (monthIndex >= 0 && monthIndex < 12) {
          result[monthIndex]['count'] = result[monthIndex]['count'] + 1;
        }
      }
    }
    
    return result;
  }
  
  // Calculate monthly revenue (last 12 months)
  List<Map<String, dynamic>> calculateMonthlyRevenue(List<Payment> payments) {
    // Initialize result with the last 12 months
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Create empty data for the last 12 months
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = Formatters.formatDate(month).substring(0, 3); // Get short month name
      
      result.add({
        'month': monthName,
        'amount': 0.0,
      });
    }
    
    // Sum payments by month
    for (final payment in payments) {
      final paymentDate = payment.date;
      
      // Only count payments from the last 12 months
      if (paymentDate.isAfter(DateTime(now.year, now.month - 11, 1))) {
        // Calculate month index relative to current month
        final monthDiff = (now.year - paymentDate.year) * 12 + now.month - paymentDate.month;
        final monthIndex = 11 - monthDiff;
        
        if (monthIndex >= 0 && monthIndex < 12) {
          result[monthIndex]['amount'] = result[monthIndex]['amount'] + payment.amount;
        }
      }
    }
    
    return result;
  }
  
  // Calculate graduation rates by course
  List<Map<String, dynamic>> calculateGraduationRates(List<Student> students, List<Course> courses) {
    final result = <Map<String, dynamic>>[];
    final courseStudents = <String, List<Student>>{};
    
    // Group students by course
    for (final student in students) {
      final course = student.courseName;
      if (!courseStudents.containsKey(course)) {
        courseStudents[course] = [];
      }
      courseStudents[course]!.add(student);
    }
    
    // Calculate graduation rate for each course
    for (final entry in courseStudents.entries) {
      final courseName = entry.key;
      final students = entry.value;
      
      // Count graduated students in this course
      final graduatedCount = students.where((s) => s.isGraduated).length;
      final totalCount = students.length;
      
      // Calculate graduation rate as percentage
      final rate = totalCount > 0 ? (graduatedCount / totalCount) * 100 : 0.0;
      
      result.add({
        'course': courseName,
        'rate': rate,
        'graduated': graduatedCount,
        'total': totalCount,
      });
    }
    
    return result;
  }
  
  // Calculate payment collection efficiency
  double calculatePaymentCollectionEfficiency(List<Student> students) {
    double totalPrice = 0.0;
    double totalPaid = 0.0;
    
    for (final student in students) {
      totalPrice += student.price;
      totalPaid += student.amountPaid;
    }
    
    return totalPrice > 0 ? (totalPaid / totalPrice) * 100 : 0.0;
  }
  
  // Calculate average course duration (in days)
  double calculateAverageCourseDuration(List<Course> courses) {
    if (courses.isEmpty) return 0.0;
    
    final totalDuration = courses.fold<int>(0, (sum, course) => sum + course.duration);
    return totalDuration / courses.length;
  }
  
  // Calculate revenue per student
  double calculateRevenuePerStudent(List<Student> students) {
    if (students.isEmpty) return 0.0;
    
    final totalRevenue = students.fold<double>(0.0, (sum, student) => sum + student.amountPaid);
    return totalRevenue / students.length;
  }
  
  // Calculate enrollment growth rate (current month vs previous month)
  double calculateEnrollmentGrowthRate(List<Student> students) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    
    // Count enrollments in current month
    final currentMonthCount = students.where((s) => 
        s.admissionDate.isAfter(currentMonthStart.subtract(Duration(days: 1)))).length;
    
    // Count enrollments in previous month
    final previousMonthCount = students.where((s) => 
        s.admissionDate.isAfter(previousMonthStart.subtract(Duration(days: 1))) && 
        s.admissionDate.isBefore(currentMonthStart)).length;
    
    // Calculate growth rate
    return previousMonthCount > 0 
        ? ((currentMonthCount - previousMonthCount) / previousMonthCount) * 100 
        : (currentMonthCount > 0 ? 100.0 : 0.0);
  }
  
  // Calculate top performing courses (by enrollment)
  List<Map<String, dynamic>> calculateTopPerformingCourses(List<Student> students, int limit) {
    final courseCounts = calculateStudentsByCourse(students);
    
    // Convert to list for sorting
    final courseList = courseCounts.entries.map((entry) => {
      'course': entry.key,
      'count': entry.value,
    }).toList();
    
    // Sort by count (descending)
    courseList.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    // Return top N courses
    return courseList.take(limit).toList();
  }
  
  // Calculate gender distribution
  Map<String, int> calculateGenderDistribution(List<Student> students) {
    final result = <String, int>{};
    
    for (final student in students) {
      final gender = student.gender;
      if (result.containsKey(gender)) {
        result[gender] = result[gender]! + 1;
      } else {
        result[gender] = 1;
      }
    }
    
    return result;
  }
  
  // Calculate education level distribution
  Map<String, int> calculateEducationDistribution(List<Student> students) {
    final result = <String, int>{};
    
    for (final student in students) {
      final education = student.educationLevel;
      if (result.containsKey(education)) {
        result[education] = result[education]! + 1;
      } else {
        result[education] = 1;
      }
    }
    
    return result;
  }
  
  // Calculate age distribution (by age groups)
  Map<String, int> calculateAgeDistribution(List<Student> students) {
    final result = {
      'Under 18': 0,
      '18-24': 0,
      '25-34': 0,
      '35-44': 0,
      '45+': 0,
    };
    
    for (final student in students) {
      final age = Formatters.calculateAge(student.dob);
      
      if (age < 18) {
        result['Under 18'] = result['Under 18']! + 1;
      } else if (age < 25) {
        result['18-24'] = result['18-24']! + 1;
      } else if (age < 35) {
        result['25-34'] = result['25-34']! + 1;
      } else if (age < 45) {
        result['35-44'] = result['35-44']! + 1;
      } else {
        result['45+'] = result['45+']! + 1;
      }
    }
    
    return result;
  }
}