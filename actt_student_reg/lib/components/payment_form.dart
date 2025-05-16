import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/formatters.dart';

// Component to display a payment form dialog
class PaymentForm extends StatefulWidget {
  final Student student;
  final double remainingAmount;
  
  const PaymentForm({
    Key? key, 
    required this.student, 
    required this.remainingAmount,
  }) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isFullPayment = false;

  @override
  void initState() {
    super.initState();
    // Initialize description with a default value
    _descriptionController.text = 'Course payment';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validate and submit the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get amount from controller or use remaining amount if full payment
      final amount = _isFullPayment
          ? widget.remainingAmount
          : double.parse(_amountController.text);
      
      // Return payment data
      Navigator.of(context).pop({
        'amount': amount,
        'description': _descriptionController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Payment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info header
              Text(
                'Student: ${widget.student.fullName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Course: ${widget.student.courseName}'),
              Text(
                'Remaining: ${Formatters.formatCurrency(widget.remainingAmount)}',
                style: TextStyle(color: Colors.red),
              ),
              Divider(height: 24),
              // Full payment checkbox
              CheckboxListTile(
                title: Text('Pay full remaining amount'),
                value: _isFullPayment,
                onChanged: (value) {
                  setState(() {
                    _isFullPayment = value ?? false;
                    if (_isFullPayment) {
                      // If full payment, set amount to remaining balance
                      _amountController.text = widget.remainingAmount.toString();
                    } else {
                      _amountController.clear();
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 8),
              // Amount field (disabled if full payment)
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: !_isFullPayment,
                validator: (value) {
                  if (_isFullPayment) return null;
                  
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    if (amount > widget.remainingAmount) {
                      return 'Amount cannot exceed remaining balance';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Record Payment'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}