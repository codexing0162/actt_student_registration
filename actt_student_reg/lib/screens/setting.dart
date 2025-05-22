// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../component/datasyc.dart'; // DataSync
// import 'package:url_launcher/url_launcher.dart';
// import 'package:actt_student_reg/component/drawer.dart';
// import '../component/nofticationtheme.dart'; // ThemeNotifier
// import 'dart:io';

// class Setting extends StatefulWidget {
//   const Setting({super.key});

//   @override
//   State<Setting> createState() => _SettingState();
// }

// class _SettingState extends State<Setting> {
//   final studentPath = 'lib/localstorage/student.json';
//   final syncedPath = 'lib/localstorage/sycdata.json';
//   final exportPath = 'lib/localstorage/exported.json';
//   final importPath = 'lib/localstorage/imported.json';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: Colors.blueGrey,
//         centerTitle: true,
//       ),
//       drawer: AppDrawer(),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           const Text(
//             'Sync Settings',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),

//           ListTile(
//             title: const Text('Manual Sync'),
//             subtitle: const Text('Sync data manually'),
//             trailing: ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final dataSync = DataSync();
//                   await dataSync.syncDataAndDelete();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Data synced and local data updated!'),
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error syncing data: $e')),
//                   );
//                 }
//               },
//               child: const Text('Sync Now'),
//             ),
//           ),

//           const Divider(),
//           const Text(
//             'Data Management',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),

//           ListTile(
//             title: const Text('Clear Local Data'),
//             subtitle: const Text('Delete all local data'),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () async {
//                 try {
//                   final studentFile = File(studentPath);
//                   final syncedFile = File(syncedPath);

//                   if (await studentFile.exists()) await studentFile.delete();
//                   if (await syncedFile.exists()) await syncedFile.delete();

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Local data cleared successfully!'),
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error clearing data: $e')),
//                   );
//                 }
//               },
//             ),
//           ),

//           ListTile(
//             title: const Text('Export Data'),
//             subtitle: const Text('Export local data as JSON'),
//             trailing: IconButton(
//               icon: const Icon(Icons.download),
//               onPressed: () async {
//                 try {
//                   final studentFile = File(studentPath);
//                   if (await studentFile.exists()) {
//                     final data = await studentFile.readAsString();
//                     final exportFile = File(exportPath);
//                     await exportFile.writeAsString(data);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Data exported successfully!'),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('No data to export!')),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error exporting data: $e')),
//                   );
//                 }
//               },
//             ),
//           ),

//           ListTile(
//             title: const Text('Import Data'),
//             subtitle: const Text('Import data from a JSON file'),
//             trailing: IconButton(
//               icon: const Icon(Icons.upload),
//               onPressed: () async {
//                 try {
//                   final importFile = File(importPath);
//                   if (await importFile.exists()) {
//                     final data = await importFile.readAsString();
//                     final studentFile = File(studentPath);
//                     await studentFile.writeAsString(data);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Data imported successfully!'),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('No imported file found!')),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error importing data: $e')),
//                   );
//                 }
//               },
//             ),
//           ),

//           const Divider(),
//           const Text(
//             'App Information',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
