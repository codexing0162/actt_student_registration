import 'package:flutter/material.dart';
import 'package:actt_student_reg/screens/home.dart';

class Startpage extends StatelessWidget {
  const Startpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Image.asset('lib/images/acttlogo.png', height: 240),
              ),

              // tittle
              Text(
                'Actt',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              // to leave a space
              const SizedBox(height: 30),

              //sub titile
              const Text(
                'welcome to affordable computer and technology for tanzania ',
                style: TextStyle(fontSize: 17, color: Colors.black),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // start button
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => homepage()),
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
