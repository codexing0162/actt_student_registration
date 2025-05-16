import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';
import '../services/google_sheets_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../components/payment_form.dart';

class PaymentTrackingScreen extends StatefulWidget {
  @override
  _PaymentTrackingScreenState createState() => _PaymentTrackingScreenState();
}

class _PaymentTrackingScreenState extends State<PaymentTrackingScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  late GoogleSheetsService _googleSheetsService;
  List<Student> _students = [];
  bool _isLoading = true;
  
  // Filtering options
  bool _showFullyPaid = false;
  String _sortBy = 'remainingPrice'; // Default sort by outstanding balance
  bool _sortAscending = false; // Default descending (highest balance first)

  @override
  void initState() {
    super.initState();
    _googleSheetsService = GoogleSheetsService(_localStorageService, Constants.googleScriptUrl);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load from Google Sheets first, fall back to local if offline
      final students = await _googleSheetsService.fetchStudents();
      
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading students: $e');
      
      // If online fetch fails, load from local storage
      final students = await _localStorageService.getStudents();
      
      setState(() {
        _students = students;
        _isLoading = false;
      });
      
      // Show offline notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Working offline. Payment changes will be synced when online.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // Apply sorting and filtering
    _sortAndFilterStudents();
  }
  
  // Sort and filter students based on current settings
  void _sortAndFilterStudents() {
    setState(() {
      // Filter fully paid students if needed
      if (!_showFullyPaid) {
        _students = _students.where((student) => !student.isFullyPaid).toList();
      }
      
      // Sort students
      _students.sort((a, b) {
        dynamic valueA;
        dynamic valueB;
        
        // Extract the appropriate field for sorting
        switch (_sortBy) {
          case 'fullName':
            valueA = a.fullName;
            valueB = b.fullName;
            break;
          case 'courseName':
            valueA = a.courseName;
            valueB = b.courseName;
            break;
          case 'price':
            valueA = a.price;
            valueB = b.price;
            break;
          case 'amountPaid':
            valueA = a.amountPaid;
            valueB = b.amountPaid;
            break;
          case 'remainingPrice':
            valueA = a.remainingPrice;
            valueB = b.remainingPrice;
            break;
          case 'paymentProgress':
            valueA = a.paymentProgress;
            valueB = b.paymentProgress;
            break;
          default:
            valueA = a.remainingPrice;
            valueB = b.remainingPrice;
        }
        
        // Compare the values based on sort direction
        int comparison;
        if (valueA is String && valueB is String) {
          comparison = valueA.compareTo(valueB);
        } else {
          comparison = valueA > valueB ? 1 : (valueA < valueB ? -1 : 0);
        }
        
        // Reverse if descending order
        return _sortAscending ? comparison : -comparison;
      });
    });
  }
  
  // Record a payment for a student
  Future<void> _recordPayment(Student student) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PaymentForm(
        student: student,
        remainingAmount: student.remainingPrice,
      ),
    );
    
    if (result != null) {
      final amount = result['amount'] as double;
      final description = result['description'] as String;
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      
      try {
        // Try to record payment online
        final success = await _googleSheetsService.recordPayment(
          student.id,
          amount,
          description,
        );
        
        // Dismiss loading dialog
        Navigator.of(context).pop();
        
        if (success) {
          // Create payment object for local storage
          final payment = Payment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            studentId: student.id,
            amount: amount,
            description: description,
            date: DateTime.now(),
          );
          
          // Save payment locally
          await _localStorageService.addPayment(payment);
          
          // Reload students to reflect payment
          await _loadStudents();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Payment will be synced later when online
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment saved locally and will be synced when online.'),
            ),
          );
          
          // Reload students to reflect local payment
          await _loadStudents();
        }
      } catch (e) {
        // Dismiss loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Tracking'),
        actions: [
          // Toggle showing fully paid students
          IconButton(
            icon: Icon(_showFullyPaid ? Icons.check_circle : Icons.check_circle_outline),
            tooltip: 'Show fully paid students',
            onPressed: () {
              setState(() {
                _showFullyPaid = !_showFullyPaid;
                _sortAndFilterStudents();
              });
            },
          ),
          // Sort options menu
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  // Toggle direction if same field
                  _sortAscending = !_sortAscending;
                } else {
                  // Set new field and reset direction
                  _sortBy = value;
                  _sortAscending = true;
                }
                _sortAndFilterStudents();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'fullName',
                child: Text('Name'),
              ),
              PopupMenuItem(
                value: 'courseName',
                child: Text('Course'),
              ),
              PopupMenuItem(
                value: 'price',
                child: Text('Total Price'),
              ),
              PopupMenuItem(
                value: 'amountPaid',
                child: Text('Amount Paid'),
              ),
              PopupMenuItem(
                value: 'remainingPrice',
                child: Text('Remaining Balance'),
              ),
              PopupMenuItem(
                value: 'paymentProgress',
                child: Text('Payment Progress'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Text(
                    _showFullyPaid
                        ? 'No students found.'
                        : 'No students with outstanding balances found.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(student.courseName),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Payment progress bar
                            LinearProgressIndicator(
                              value: student.paymentProgress / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                student.isFullyPaid ? Colors.green : Colors.blue,
                              ),
                              minHeight: 10,
                            ),
                            SizedBox(height: 8),
                            // Payment details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Paid: ${Formatters.formatCurrency(student.amountPaid)}',
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  'Remaining: ${Formatters.formatCurrency(student.remainingPrice)}',
                                  style: TextStyle(
                                    color: student.isFullyPaid
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Total: ${Formatters.formatCurrency(student.price)}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 16),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.history),
                                  label: Text('History'),
                                  onPressed: () {
                                    // Navigate to payment history
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentHistoryScreen(
                                          studentId: student.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.payment),
                                  label: Text('Record Payment'),
                                  onPressed: student.isFullyPaid
                                      ? null // Disable if fully paid
                                      : () => _recordPayment(student),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        onPressed: _loadStudents,
      ),
    );
  }
}

// Placeholder for PaymentHistoryScreen - you would implement this separately
class PaymentHistoryScreen extends StatelessWidget {
  final String studentId;
  
  const PaymentHistoryScreen({Key? key, required this.studentId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: Center(
        child: Text('Payment history for student $studentId'),
      ),
    );
  }
}