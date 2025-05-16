import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/formatters.dart';
import '../utils/date_utils.dart' as date_utils;

// Reusable card to display student information in a list
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  
  const StudentCard({
    Key? key,
    required this.student,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate days remaining or days since completion
    final now = DateTime.now();
    final daysLeft = student.completionDate != null
        ? student.completionDate!.difference(now).inDays
        : student.expectedCompletionDate.difference(now).inDays;
    
    // Determine if student is currently active or already completed
    final isCompleted = student.completionDate != null;
    final isActive = !isCompleted && daysLeft >= 0;
    final isOverdue = !isCompleted && daysLeft < 0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and status chip
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(isCompleted, isActive, isOverdue),
                ],
              ),
              SizedBox(height: 8),
              // Course info
              Text('Course: ${student.courseName}'),
              SizedBox(height: 4),
              // Trainer info
              Text('Trainer: ${student.trainerName}'),
              SizedBox(height: 8),
              // Dates and duration info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Admitted: ${Formatters.formatDate(student.admissionDate)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    isCompleted
                        ? 'Completed: ${Formatters.formatDate(student.completionDate!)}'
                        : 'Expected completion: ${Formatters.formatDate(student.expectedCompletionDate)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Payment progress
              _buildPaymentProgress(),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build the status chip based on student status
  Widget _buildStatusChip(bool isCompleted, bool isActive, bool isOverdue) {
    Color chipColor;
    String statusText;
    
    if (isCompleted) {
      chipColor = Colors.green;
      statusText = 'Graduated';
    } else if (isActive) {
      chipColor = Colors.blue;
      statusText = 'Active';
    } else if (isOverdue) {
      chipColor = Colors.orange;
      statusText = 'Overdue';
    } else {
      chipColor = Colors.grey;
      statusText = 'Unknown';
    }
    
    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
    );
  }
  
  // Build payment progress indicator
  Widget _buildPaymentProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment Progress'),
            Text(
              '${student.paymentProgress.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: student.isFullyPaid ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: student.paymentProgress / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            student.isFullyPaid ? Colors.green : Colors.blue,
          ),
          minHeight: 8,
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid: ${Formatters.formatCurrency(student.amountPaid)}',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
            Text(
              'Remaining: ${Formatters.formatCurrency(student.remainingPrice)}',
              style: TextStyle(
                fontSize: 12,
                color: student.isFullyPaid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}