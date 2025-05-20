import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBody extends StatefulWidget {
  const AdminBody({Key? key}) : super(key: key);

  @override
  State<AdminBody> createState() => _AdminBodyState();
}

class _AdminBodyState extends State<AdminBody> {
  int studentCount = 0;
  int userCount = 0;
  String? studentPath;
  String? userPath;

  @override
  void initState() {
    super.initState();
    _loadPaths().then((_) => _loadCounts());
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    studentPath = prefs.getString('studentPath');
    userPath = prefs.getString('userPath');

    if (studentPath == null || userPath == null) {
      final dir = await getApplicationDocumentsDirectory();
      studentPath = '${dir.path}/student.json';
      userPath = '${dir.path}/user.json';

      await prefs.setString('studentPath', studentPath!);
      await prefs.setString('userPath', userPath!);
    }
  }

  Future<void> _loadCounts() async {
    await Future.wait([
      _fetchCount(studentPath!, 'students', (count) => studentCount = count),
      _fetchCount(userPath!, 'users', (count) => userCount = count),
    ]);
    setState(() {});
  }

  Future<void> _fetchCount(
    String path,
    String key,
    void Function(int) setCount,
  ) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        final count = (data[key] as List?)?.length ?? 0;
        setCount(count);
      } else {
        setCount(0);
      }
    } catch (_) {
      setCount(0);
    }
  }

  Future<void> _changePath(String type) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select $type JSON File',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final prefs = await SharedPreferences.getInstance();
      if (type == 'student') {
        studentPath = path;
        await prefs.setString('studentPath', path);
      } else {
        userPath = path;
        await prefs.setString('userPath', path);
      }
      await _loadCounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _InfoBox(
              label: 'Students',
              count: studentCount,
              color: Colors.blue,
              icon: Icons.school,
              onTap: () => _changePath('student'),
              path: studentPath,
            ),
            _InfoBox(
              label: 'Users',
              count: userCount,
              color: Colors.green,
              icon: Icons.people,
              onTap: () => _changePath('user'),
              path: userPath,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/addStudent'),
        label: const Text("Add Student"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final String? path;

  const _InfoBox({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color.withOpacity(0.1),
        child: SizedBox(
          width: 180,
          height: 130,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 10),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label, style: TextStyle(color: color)),
                if (path != null)
                  Text(
                    '📁 ${path!.split('/').last}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
