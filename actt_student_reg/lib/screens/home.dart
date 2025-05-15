import 'package:flutter/material.dart';
import 'package:actt_student_reg/component/form.dart';
import 'package:actt_student_reg/screens/setting.dart';
import 'package:actt_student_reg/screens/studentlist.dart';

class homepage extends StatelessWidget {
  const homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // header
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        toolbarHeight: 70,
        title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Image.asset('lib/images/acttlogo.png'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Handle home tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Student List'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentList()),
                );
                // Handle student list tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                // to setting page
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
                );
              },
            ),
          ],
        ),
      ),

      //body
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              const Text(
                'Welcome to ACTT',
                style: TextStyle(fontSize: 20, fontFamily: 'Serif'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Afordable Computer and Technology Tanzania',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Serif',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  //Navigate to Student Registration Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterForm(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add New Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontFamily: 'Serif'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
