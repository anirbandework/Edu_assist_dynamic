import 'package:flutter/material.dart';
import '../../../../core/models/class_model.dart';

class AssignClassroomsDialog extends StatefulWidget {
  final List<String> selectedIds;
  final List<ClassModel> items;
  const AssignClassroomsDialog({super.key, required this.selectedIds, required this.items});

  @override
  State<AssignClassroomsDialog> createState() => _AssignClassroomsDialogState();
}

class _AssignClassroomsDialogState extends State<AssignClassroomsDialog> {
  final Map<String, TextEditingController> roomCtrls = {};

  @override
  void initState() {
    super.initState();
    for (final id in widget.selectedIds) {
      final m = widget.items.firstWhere((e) => e.id == id);
      roomCtrls[id] = TextEditingController(text: m.classroom ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Classrooms'),
      content: SizedBox(
        width: 500,
        child: ListView(
          shrinkWrap: true,
          children: widget.selectedIds.map((id) {
            final m = widget.items.firstWhere((e) => e.id == id);
            return ListTile(
              title: Text(m.className),
              subtitle: TextField(controller: roomCtrls[id], decoration: const InputDecoration(labelText: 'Room (leave empty to clear)')),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final map = <String, String?>{};
            for (final id in widget.selectedIds) {
              final v = roomCtrls[id]!.text.trim();
              map[id] = v.isEmpty ? null : v;
            }
            Navigator.pop(context, map);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
