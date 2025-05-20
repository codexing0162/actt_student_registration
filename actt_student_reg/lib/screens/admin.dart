import 'package:flutter/material.dart';
import 'package:actt_student_reg/component/adminbody.dart';
import 'package:actt_student_reg/component/admindrawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: Admindrawer(),
      body: AdminBody()
    );
  }
}
