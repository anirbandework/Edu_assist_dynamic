import 'package:flutter/material.dart';

class ConfirmBulkDeleteDialog extends StatelessWidget {
  final int count;
  const ConfirmBulkDeleteDialog({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Classes'),
      content: Text('Are you sure you want to delete $count classes? This performs a soft delete.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    );
  }
}
