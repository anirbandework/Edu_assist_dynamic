import 'package:flutter/material.dart';

class RolloverDialog extends StatefulWidget {
  final List<String> selectedIds;
  const RolloverDialog({super.key, required this.selectedIds});

  @override
  State<RolloverDialog> createState() => _RolloverDialogState();
}

class _RolloverDialogState extends State<RolloverDialog> {
  final from = TextEditingController();
  final to = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Academic Year Rollover'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: from, decoration: const InputDecoration(labelText: 'From (e.g., 2024-25)')),
          TextField(controller: to, decoration: const InputDecoration(labelText: 'To (e.g., 2025-26)')),
          if (widget.selectedIds.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Applies to ${widget.selectedIds.length} selected classes (or all if none selected).'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop<Map<String, dynamic>>(context, {
            'from': from.text.trim(),
            'to': to.text.trim(),
            'ids': widget.selectedIds.isEmpty ? null : widget.selectedIds,
          }),
          child: const Text('Run'),
        ),
      ],
    );
  }
}
