import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:actt_student_reg/screens/admin.dart';
import 'package:actt_student_reg/component/form.dart';
import 'package:actt_student_reg/screens/teacher.dart';
import 'package:actt_student_reg/screens/startpage.dart';
import 'package:actt_student_reg/component/datasyc.dart';
import 'package:actt_student_reg/component/nofticationtheme.dart'; // Import ThemeNotifier

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final dataSync = DataSync();
    await dataSync.syncDataAndDelete();
    return Future.value(true);
  });
}

void main() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "syncTask",
    "syncData",
    frequency: const Duration(hours: 24),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Provide ThemeNotifier
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: themeNotifier.currentTheme, // Use the current theme
      debugShowCheckedModeBanner: false,
      home: const Startpage(), // Set the home screen
      routes: {
        '/admin': (context) => const AdminDashboard(),
        '/teacher': (context) => const TeacherDashboard(),
        '/addStudent': (context) => const RegisterForm(),
      },
    );
  }
}
