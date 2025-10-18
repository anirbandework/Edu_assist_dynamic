import 'package:flutter/material.dart';

class UpdateStudentCountDialog extends StatefulWidget {
  final int maxCount;
  final int current;
  const UpdateStudentCountDialog({super.key, required this.maxCount, required this.current});
  @override
  State<UpdateStudentCountDialog> createState() => _UpdateStudentCountDialogState();
}

class _UpdateStudentCountDialogState extends State<UpdateStudentCountDialog> {
  late TextEditingController ctrl;
  @override
  void initState() { super.initState(); ctrl = TextEditingController(text: widget.current.toString()); }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Student Count'),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: 'New Count (max ${widget.maxCount})'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final v = int.tryParse(ctrl.text) ?? widget.current;
            if (v <= widget.maxCount) {
              Navigator.pop<int>(context, v);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exceeds max capacity')),
              );
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
