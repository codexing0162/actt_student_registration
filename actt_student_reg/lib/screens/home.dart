import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../services/statistics_service.dart';
import '../components/app_drawer.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final StatisticsService _statisticsService = StatisticsService();
  final AuthService _authService = AuthService();
  late GoogleSheetsService _googleSheetsService;
  
  bool _isLoading = true;
  User? _currentUser;
  
  // Dashboard statistics
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _graduatedStudents = 0;
  double _totalRevenue = 0.0;
  double _outstandingBalance = 0.0;
  bool _isSyncRequired = false;
  List<Student> _recentStudents = [];
  List<Map<String, dynamic>> _pendingPayments = [];

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user
      _currentUser = await _authService.getCurrentUser();
      
      // Load students
      final students = await _localStorageService.getStudents();
      
      // Calculate statistics
      _totalStudents = students.length;
      _activeStudents = students.where((s) => !s.isGraduated).length;
      _graduatedStudents = students.where((s) => s.isGraduated).length;
      
      // Get payment data
      final payments = await _localStorageService.getPayments();
      _totalRevenue = payments.fold(0.0, (sum, payment) => sum + payment.amount);
      _outstandingBalance = students.fold(0.0, (sum, student) => sum + student.remainingPrice);
      
      // Check if sync is required
      _isSyncRequired = await _localStorageService.isSyncRequired();
      
      // Get recent students (last 5)
      _recentStudents = students.sublist(
        0,
        students.length > 5 ? 5 : students.length,
      );
      
      // Get students with pending payments
      final studentsWithPayments = students
          .where((s) => s.remainingPrice > 0)
          .toList()
        ..sort((a, b) => b.remainingPrice.compareTo(a.remainingPrice));
      
      _pendingPayments = studentsWithPayments
          .take(5)
          .map((s) => {
            'student': s,
            'amount': s.remainingPrice,
            'progress': s.paymentProgress,
          })
          .toList();
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACTT Registration'),
        actions: [
          // Show sync indicator if required
          if (_isSyncRequired)
            IconButton(
              icon: Icon(Icons.sync_problem),
              tooltip: 'Sync Required',
              onPressed: () {
                // Navigate to sync history screen
                Navigator.pushNamed(context, '/sync-history');
              },
            ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    _buildWelcomeCard(),
                    SizedBox(height: 16),
                    
                    // Quick stats
                    _buildQuickStatsSection(),
                    SizedBox(height: 24),
                    
                    // Recent students
                    _buildRecentStudentsSection(),
                    SizedBox(height: 24),
                    
                    // Pending payments
                    _buildPendingPaymentsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add student screen
          Navigator.pushNamed(context, '/student-form');
        },
        label: Text('Add Student'),
        icon: Icon(Icons.add),
      ),
    );
  }
  
  // Build welcome card with user info and sync status
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_currentUser?.fullName ?? 'User'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getRoleText(_currentUser?.role ?? AppRole.teacher),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date display
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      Formatters.formatDate(DateTime.now()),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                // Sync status
                Row(
                  children: [
                    Icon(
                      _isSyncRequired ? Icons.sync_problem : Icons.sync,
                      size: 16,
                      color: _isSyncRequired ? Colors.orange : Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isSyncRequired
                          ? 'Sync required'
                          : 'Data synchronized',
                      style: TextStyle(
                        color: _isSyncRequired ? Colors.orange : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build quick stats section
  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildStatCard(
                title: 'Total Students',
                value: '$_totalStudents',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildStatCard(
                title: 'Active',
                value: '$_activeStudents',
                icon: Icons.person,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildStatCard(
                title: 'Graduated',
                value: '$_graduatedStudents',
                icon: Icons.school,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '\$${_totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.teal,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Outstanding',
                value: '\$${_outstandingBalance.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Build recent students section
  Widget _buildRecentStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to student list
                Navigator.pushNamed(context, '/student-list');
              },
              child: Text('View All'),
            ),
          ],
        ),
        _recentStudents.isEmpty
            ? Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No students registered yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            : Column(
                children: _recentStudents.map((student) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(student.fullName),
                      subtitle: Text(student.courseName),
                      trailing: _buildStatusChip(student),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          student.fullName.isNotEmpty
                              ? student.fullName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      onTap: () {
                        // Navigate to student details
                        Navigator.pushNamed(
                          context,
                          '/student-form',
                          arguments: student,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
  
  // Build pending payments section
  Widget _buildPendingPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to payment tracking
                Navigator.pushNamed(context, '/payment-tracking');
              },
              child: Text('View All'),
            ),
          ],
        ),
        _pendingPayments.isEmpty
            ? Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No pending payments',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            : Column(
                children: _pendingPayments.map((payment) {
                  final student = payment['student'] as Student;
                  final amount = payment['amount'] as double;
                  final progress = payment['progress'] as double;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  student.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            student.courseName,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            minHeight: 8,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${progress.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
  
  // Build stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build status chip for student
  Widget _buildStatusChip(Student student) {
    if (student.isGraduated) {
      return Chip(
        label: Text(
          'Graduated',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        backgroundColor: Colors.green,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 8),
      );
    } else {
      return Chip(
        label: Text(
          'Active',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        backgroundColor: Colors.blue,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 8),
      );
    }
  }
  
  // Get human-readable role text
  String _getRoleText(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Administrator';
      case AppRole.teacher:
        return 'Teacher';
      case AppRole.accounting:
        return 'Accounting / Sales';
      default:
        return 'Staff';
    }
  }
}