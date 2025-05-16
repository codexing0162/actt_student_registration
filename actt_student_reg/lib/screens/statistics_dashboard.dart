import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/statistics_service.dart';
import '../components/statistics_chart.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/course.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  @override
  _StatisticsDashboardScreenState createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> with SingleTickerProviderStateMixin {
  final LocalStorageService _localStorageService = LocalStorageService();
  final StatisticsService _statisticsService = StatisticsService();
  
  bool _isLoading = true;
  late TabController _tabController;
  
  // Statistics data
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _graduatedStudents = 0;
  double _totalRevenue = 0.0;
  double _outstandingBalance = 0.0;
  Map<String, int> _studentsByCourse = {};
  Map<String, double> _revenueByCourse = {};
  List<Map<String, dynamic>> _monthlyEnrollment = [];
  List<Map<String, dynamic>> _monthlyRevenue = [];
  List<Map<String, dynamic>> _graduationRates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all required data
      final students = await _localStorageService.getStudents();
      final payments = await _localStorageService.getPayments();
      final courses = await _localStorageService.getCourses();
      
      // Generate statistics
      _totalStudents = students.length;
      _activeStudents = students.where((s) => !s.isGraduated).length;
      _graduatedStudents = students.where((s) => s.isGraduated).length;
      
      _totalRevenue = payments.fold(0.0, (sum, payment) => sum + payment.amount);
      _outstandingBalance = students.fold(0.0, (sum, student) => sum + student.remainingPrice);
      
      // Students by course
      _studentsByCourse = _statisticsService.calculateStudentsByCourse(students);
      
      // Revenue by course
      _revenueByCourse = _statisticsService.calculateRevenueByCourse(students);
      
      // Monthly enrollment
      _monthlyEnrollment = _statisticsService.calculateMonthlyEnrollment(students);
      
      // Monthly revenue
      _monthlyRevenue = _statisticsService.calculateMonthlyRevenue(payments);
      
      // Graduation rates
      _graduationRates = _statisticsService.calculateGraduationRates(students, courses);
      
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading statistics: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: Text('Statistics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.school), text: 'Enrollment'),
            Tab(icon: Icon(Icons.payments), text: 'Financials'),
            Tab(icon: Icon(Icons.insights), text: 'Performance'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(),
                
                // Enrollment Tab
                _buildEnrollmentTab(),
                
                // Financials Tab
                _buildFinancialsTab(),
                
                // Performance Tab
                _buildPerformanceTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        onPressed: _loadData,
      ),
    );
  }
  
  // Build the overview tab with key metrics
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildSectionHeader('Key Performance Indicators'),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Students',
                  value: '$_totalStudents',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Active Students',
                  value: '$_activeStudents',
                  icon: Icons.person,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Graduated',
                  value: '$_graduatedStudents',
                  icon: Icons.school,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Graduation Rate',
                  value: _totalStudents > 0
                      ? '${(_graduatedStudents / _totalStudents * 100).toStringAsFixed(1)}%'
                      : '0%',
                  icon: Icons.insights,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Revenue',
                  value: '\$${_totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.teal,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Outstanding',
                  value: '\$${_outstandingBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Students by Course Chart
          _buildSectionHeader('Students by Course'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.pie,
              data: _studentsByCourse.entries.map((entry) => {
                'name': entry.key,
                'value': entry.value,
              }).toList(),
              xAxisKey: 'name',
              yAxisKey: 'value',
              colorScheme: ColorScheme.light(),
            ),
          ),
          SizedBox(height: 24),
          
          // Monthly Enrollment Chart
          _buildSectionHeader('Monthly Enrollment'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.bar,
              data: _monthlyEnrollment,
              xAxisKey: 'month',
              yAxisKey: 'count',
              colorScheme: ColorScheme.light(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the enrollment tab
  Widget _buildEnrollmentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Enrollment Trend
          _buildSectionHeader('Enrollment Trends'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.line,
              data: _monthlyEnrollment,
              xAxisKey: 'month',
              yAxisKey: 'count',
              colorScheme: ColorScheme.light(),
            ),
          ),
          SizedBox(height: 24),
          
          // Course Popularity
          _buildSectionHeader('Course Popularity'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.bar,
              data: _studentsByCourse.entries.map((entry) => {
                'name': entry.key,
                'value': entry.value,
              }).toList(),
              xAxisKey: 'name',
              yAxisKey: 'value',
              colorScheme: ColorScheme.light(),
            ),
          ),
          SizedBox(height: 24),
          
          // Detailed Course Statistics
          _buildSectionHeader('Course Details'),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _studentsByCourse.length,
            itemBuilder: (context, index) {
              final entry = _studentsByCourse.entries.elementAt(index);
              final courseName = entry.key;
              final studentCount = entry.value;
              final revenue = _revenueByCourse[courseName] ?? 0.0;
              
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Students: $studentCount'),
                          Text('Revenue: \$${revenue.toStringAsFixed(2)}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalStudents > 0
                            ? studentCount / _totalStudents
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 10,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share: ${(_totalStudents > 0 ? (studentCount / _totalStudents * 100) : 0).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Build the financials tab
  Widget _buildFinancialsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial KPIs
          _buildSectionHeader('Financial Summary'),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Revenue',
                  value: '\$${_totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.teal,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Outstanding',
                  value: '\$${_outstandingBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Collection Rate',
                  value: _totalRevenue + _outstandingBalance > 0
                      ? '${(_totalRevenue / (_totalRevenue + _outstandingBalance) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Avg Revenue/Student',
                  value: _totalStudents > 0
                      ? '\$${(_totalRevenue / _totalStudents).toStringAsFixed(2)}'
                      : '\$0.00',
                  icon: Icons.person,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Monthly Revenue Chart
          _buildSectionHeader('Monthly Revenue'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.line,
              data: _monthlyRevenue,
              xAxisKey: 'month',
              yAxisKey: 'amount',
              colorScheme: ColorScheme.light(),
            ),
          ),
          SizedBox(height: 24),
          
          // Revenue by Course Chart
          _buildSectionHeader('Revenue by Course'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.pie,
              data: _revenueByCourse.entries.map((entry) => {
                'name': entry.key,
                'value': entry.value,
              }).toList(),
              xAxisKey: 'name',
              yAxisKey: 'value',
              colorScheme: ColorScheme.light(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the performance tab
  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graduation Rates
          _buildSectionHeader('Graduation Rates'),
          Container(
            height: 300,
            child: StatisticsChart(
              chartType: ChartType.bar,
              data: _graduationRates,
              xAxisKey: 'course',
              yAxisKey: 'rate',
              colorScheme: ColorScheme.light(),
            ),
          ),
          SizedBox(height: 24),
          
          // Performance Metrics
          _buildSectionHeader('Overall Performance'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPerformanceMetric(
                    label: 'Enrollment Growth',
                    value: _monthlyEnrollment.length >= 2
                        ? _calculateGrowthRate(
                            _monthlyEnrollment[_monthlyEnrollment.length - 2]['count'] as int,
                            _monthlyEnrollment.last['count'] as int,
                          )
                        : 0,
                  ),
                  SizedBox(height: 16),
                  _buildPerformanceMetric(
                    label: 'Revenue Growth',
                    value: _monthlyRevenue.length >= 2
                        ? _calculateGrowthRate(
                            _monthlyRevenue[_monthlyRevenue.length - 2]['amount'] as double,
                            _monthlyRevenue.last['amount'] as double,
                          )
                        : 0,
                  ),
                  SizedBox(height: 16),
                  _buildPerformanceMetric(
                    label: 'Course Completion',
                    value: _totalStudents > 0
                        ? _graduatedStudents / _totalStudents * 100
                        : 0,
                  ),
                  SizedBox(height: 16),
                  _buildPerformanceMetric(
                    label: 'Payment Collection',
                    value: _totalRevenue + _outstandingBalance > 0
                        ? _totalRevenue / (_totalRevenue + _outstandingBalance) * 100
                        : 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper to build KPI cards
  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }
  
  // Helper to build performance metrics
  Widget _buildPerformanceMetric({
    required String label,
    required double value,
  }) {
    // Determine color based on value
    Color color;
    if (value < 0) {
      color = Colors.red;
    } else if (value < 50) {
      color = Colors.orange;
    } else if (value < 80) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Icon(
                  value >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '${value.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: value.abs() / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
      ],
    );
  }
  
  // Calculate growth rate between two values
  double _calculateGrowthRate(num previous, num current) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return (current - previous) / previous * 100;
  }
}

// Enum for chart types
enum ChartType {
  bar,
  line,
  pie,
  scatter,
}

// Placeholder for StatisticsChart component
class StatisticsChart extends StatelessWidget {
  final ChartType chartType;
  final List<Map<String, dynamic>> data;
  final String xAxisKey;
  final String yAxisKey;
  final ColorScheme colorScheme;
  
  const StatisticsChart({
    Key? key,
    required this.chartType,
    required this.data,
    required this.xAxisKey,
    required this.yAxisKey,
    required this.colorScheme,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // In a real app, you would implement this with a charting library
    // like fl_chart, charts_flutter, or syncfusion_flutter_charts
    return Center(
      child: Text(
        'Chart: ${chartType.toString()} with ${data.length} data points',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}