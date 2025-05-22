import 'package:flutter/material.dart';

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({super.key, required this.student});

  Widget _buildInfoTile(String label, dynamic value, {IconData? icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value != null ? value.toString() : '-',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student['fullName'] ?? 'Student Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blueGrey[100],
                child: Text(
                  ((student['fullName'] != null &&
                          (student['fullName'] as String).isNotEmpty)
                      ? (student['fullName'] as String)[0].toUpperCase()
                      : 'S'),
                  style: const TextStyle(fontSize: 40, color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                student['fullName'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                student['courseName'] ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const Divider(height: 32, thickness: 1.2),
              _buildInfoTile(
                'Student ID',
                student['Student'],
                icon: Icons.badge,
              ),
              _buildInfoTile('Date of Birth', student['dob'], icon: Icons.cake),
              _buildInfoTile('Gender', student['gender'], icon: Icons.person),
              _buildInfoTile(
                'Postal Address',
                student['postalAddress'],
                icon: Icons.home,
              ),
              _buildInfoTile('Phone', student['phone'], icon: Icons.phone),
              _buildInfoTile(
                'Emergency Phone',
                student['emergencyPhone'],
                icon: Icons.phone_in_talk,
              ),
              _buildInfoTile(
                'Education Level',
                student['educationLevel'],
                icon: Icons.school,
              ),
              _buildInfoTile(
                'Trainer Name',
                student['trainerName'],
                icon: Icons.person_outline,
              ),
              _buildInfoTile(
                'Admission Date',
                student['admissionDate'],
                icon: Icons.calendar_today,
              ),
              _buildInfoTile(
                'Completion Date',
                student['completionDate'],
                icon: Icons.event_available,
              ),
              _buildInfoTile(
                'Duration',
                student['duration'],
                icon: Icons.timer,
              ),
              _buildInfoTile(
                'Course Price',
                student['price'],
                icon: Icons.attach_money,
              ),
              _buildInfoTile(
                'Amount Paid',
                student['amountPaid'],
                icon: Icons.payments,
              ),
              _buildInfoTile(
                'Remaining Price',
                student['remainingPrice'],
                icon: Icons.money_off,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
