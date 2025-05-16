import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';
import '../utils/formatters.dart';

class PaymentRecordsScreen extends StatefulWidget {
  @override
  _PaymentRecordsScreenState createState() => _PaymentRecordsScreenState();
}

class _PaymentRecordsScreenState extends State<PaymentRecordsScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  
  bool _isLoading = true;
  List<Payment> _payments = [];
  Map<String, Student> _studentsMap = {};
  
  // Filtering options
  String _searchQuery = '';
  String _sortBy = 'date'; // Default sort by date
  bool _sortAscending = false; // Default descending (newest first)

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load payments
      final payments = await _localStorageService.getPayments();
      
      // Load students to get names
      final students = await _localStorageService.getStudents();
      final studentsMap = <String, Student>{};
      for (final student in students) {
        studentsMap[student.id] = student;
      }
      
      setState(() {
        _payments = payments;
        _studentsMap = studentsMap;
        _isLoading = false;
      });
      
      // Apply filtering and sorting
      _filterAndSortPayments();
    } catch (e) {
      debugPrint('Error loading payment records: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Filter and sort payments
  void _filterAndSortPayments() {
    // Apply search filter if needed
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _payments = _payments.where((payment) {
        final student = _studentsMap[payment.studentId];
        if (student == null) return false;
        
        return student.fullName.toLowerCase().contains(query) ||
               payment.description.toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort payments
    _payments.sort((a, b) {
      dynamic valueA;
      dynamic valueB;
      
      // Extract the appropriate field for sorting
      switch (_sortBy) {
        case 'date':
          valueA = a.date;
          valueB = b.date;
          break;
        case 'amount':
          valueA = a.amount;
          valueB = b.amount;
          break;
        case 'student':
          valueA = _studentsMap[a.studentId]?.fullName ?? '';
          valueB = _studentsMap[b.studentId]?.fullName ?? '';
          break;
        default:
          valueA = a.date;
          valueB = b.date;
      }
      
      // Compare the values based on sort direction
      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.compareTo(valueB);
      } else if (valueA is DateTime && valueB is DateTime) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = valueA > valueB ? 1 : (valueA < valueB ? -1 : 0);
      }
      
      // Reverse if descending order
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Records'),
        actions: [
          // Search button
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              showSearch(
                context: context,
                delegate: PaymentSearchDelegate(
                  payments: _payments,
                  studentsMap: _studentsMap,
                  onSelected: (payment) {
                    // Show payment details
                    _showPaymentDetails(payment);
                  },
                ),
              );
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
                  _sortAscending = value == 'date' ? false : true;
                }
                _filterAndSortPayments();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Text('Date'),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Text('Amount'),
              ),
              PopupMenuItem(
                value: 'student',
                child: Text('Student Name'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No payment records found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    final student = _studentsMap[payment.studentId];
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          student?.fullName ?? 'Unknown Student',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(payment.description),
                            SizedBox(height: 4),
                            Text(
                              Formatters.formatDateTime(payment.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          Formatters.formatCurrency(payment.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () => _showPaymentDetails(payment),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
        onPressed: _loadData,
      ),
    );
  }
  
  // Show payment details in a dialog
  void _showPaymentDetails(Payment payment) {
    final student = _studentsMap[payment.studentId];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(student?.fullName ?? 'Unknown Student'),
            SizedBox(height: 16),
            Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              Formatters.formatCurrency(payment.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(payment.description),
            SizedBox(height: 16),
            Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(Formatters.formatDateTime(payment.date)),
            if (payment.receiptNumber != null) ...[
              SizedBox(height: 16),
              Text(
                'Receipt Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(payment.receiptNumber!),
            ],
            if (payment.paymentMethod != null) ...[
              SizedBox(height: 16),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(payment.paymentMethod!),
            ],
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// Search delegate for payments
class PaymentSearchDelegate extends SearchDelegate<Payment> {
  final List<Payment> payments;
  final Map<String, Student> studentsMap;
  final Function(Payment) onSelected;
  
  PaymentSearchDelegate({
    required this.payments,
    required this.studentsMap,
    required this.onSelected,
  });
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, payments.first);
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text('Search by student name or description'),
      );
    }
    
    final results = payments.where((payment) {
      final student = studentsMap[payment.studentId];
      if (student == null) return false;
      
      return student.fullName.toLowerCase().contains(query.toLowerCase()) ||
             payment.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    return results.isEmpty
        ? Center(
            child: Text('No results found'),
          )
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final payment = results[index];
              final student = studentsMap[payment.studentId];
              
              return ListTile(
                title: Text(
                  student?.fullName ?? 'Unknown Student',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(payment.description),
                trailing: Text(
                  Formatters.formatCurrency(payment.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  close(context, payment);
                  onSelected(payment);
                },
              );
            },
          );
  }
}