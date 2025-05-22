import 'package:flutter/material.dart';
import 'package:actt_student_reg/component/datasyc.dart';

class ActionSyncButton extends StatefulWidget {
  const ActionSyncButton({super.key});

  @override
  State<ActionSyncButton> createState() => _ActionSyncButtonState();
}

class _ActionSyncButtonState extends State<ActionSyncButton> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    final syncer = DataSync();
    final resultMessage = await syncer.pushAndDeleteStudentData();

    setState(() {
      _isSyncing = false;
    });

    // Show SnackBar with the result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage),
        backgroundColor:
            resultMessage.startsWith('✅') ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          _isSyncing
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.cloud_upload),
      tooltip: 'Push & Clear Student Data',
      onPressed: _isSyncing ? null : _handleSync,
    );
  }
}
