import 'package:flutter/material.dart';
import '../../../../core/models/class_model.dart';

class ClassDetailsDialog extends StatefulWidget {
  final ClassModel model;
  final Future<Map<String, dynamic>> Function() fetch;
  const ClassDetailsDialog({super.key, required this.model, required this.fetch});

  @override
  State<ClassDetailsDialog> createState() => _ClassDetailsDialogState();
}

class _ClassDetailsDialogState extends State<ClassDetailsDialog> {
  Map<String, dynamic>? details;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final d = await widget.fetch(); if (mounted) setState(() => details = d); }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return AlertDialog(
      title: Text(m.className),
      content: SizedBox(
        width: 520,
        child: details == null
            ? const LinearProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(title: const Text('Grade'), trailing: Text('${m.gradeLevel}-${m.section}')),
                  ListTile(title: const Text('Year'), trailing: Text(m.academicYear)),
                  ListTile(title: const Text('Capacity'), trailing: Text('${m.currentStudents}/${m.maximumStudents}')),
                  ListTile(title: const Text('Room'), trailing: Text(m.classroom ?? '-')),
                  ListTile(title: const Text('Status'), trailing: Text(m.isActive ? 'Active' : 'Inactive')),
                ],
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
