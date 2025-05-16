import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/studentlist.dart';
import 'screens/student_form.dart';
import 'screens/payment_tracking.dart';
import 'screens/payment_records.dart';
import 'screens/graduated_students.dart';
import 'screens/statistics_dashboard.dart';
import 'screens/course_management.dart';
import 'screens/user_management.dart';
import 'screens/setting.dart';
import 'screens/sync_history.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';
import 'models/student.dart';

class App extends StatelessWidget {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACTT Student Registration',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Use system font for better performance
        fontFamily: 'Roboto',
        // Apply consistent text theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        // Use consistent card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.zero,
        ),
        // Use consistent input decoration
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        // Use consistent button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Define app routes for navigation
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _checkIfLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/acttlogo.png',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              );
            }
            
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? HomeScreen() : LoginScreen();
          },
        ),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/student-list': (context) => StudentListScreen(),
        '/student-form': (context) => StudentFormScreen(
          onStudentUpdated: (student) {
            // Navigate back to student list after add/edit
            Navigator.pushReplacementNamed(context, '/student-list');
          },
        ),
        '/payment-tracking': (context) => PaymentTrackingScreen(),
        '/payment-records': (context) => PaymentRecordsScreen(),
        '/graduated-students': (context) => GraduatedStudentsScreen(),
        '/statistics-dashboard': (context) => StatisticsDashboardScreen(),
        '/course-management': (context) => CourseManagementScreen(),
        '/user-management': (context) => UserManagementScreen(),
        '/settings': (context) => SettingScreen(),
        '/sync-history': (context) => SyncHistoryScreen(),
      },
      // Initial route
      initialRoute: '/',
      // Error handling for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text('Page not found!'),
            ),
          ),
        );
      },
      // Handle dynamic routes and arguments
      onGenerateRoute: (settings) {
        // Handle route with arguments
        if (settings.name == '/student-form' && settings.arguments != null) {
          final student = settings.arguments as Student;
          return MaterialPageRoute(
            builder: (context) => StudentFormScreen(
              student: student,
              onStudentUpdated: (student) {
                // Navigate back to student list after edit
                Navigator.pushReplacementNamed(context, '/student-list');
              },
            ),
          );
        }
        
        // Handle other dynamic routes as needed
        return null;
      },
    );
  }
  
  // Check if user is logged in
  Future<bool> _checkIfLoggedIn() async {
    // Check if user is authenticated
    return await _authService.isAuthenticated();
  }
}