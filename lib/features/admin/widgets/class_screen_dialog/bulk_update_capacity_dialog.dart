import 'package:flutter/material.dart';
import '../../../../core/models/class_model.dart';

class BulkUpdateCapacityDialog extends StatefulWidget {
  final List<String> selectedIds;
  final List<ClassModel> items;
  const BulkUpdateCapacityDialog({super.key, required this.selectedIds, required this.items});

  @override
  State<BulkUpdateCapacityDialog> createState() => _BulkUpdateCapacityDialogState();
}

class _BulkUpdateCapacityDialogState extends State<BulkUpdateCapacityDialog> {
  final Map<String, TextEditingController> maxCtrls = {};
  final Map<String, TextEditingController> curCtrls = {};

  @override
  void initState() {
    super.initState();
    for (final id in widget.selectedIds) {
      final m = widget.items.firstWhere((e) => e.id == id);
      maxCtrls[id] = TextEditingController(text: m.maximumStudents.toString());
      curCtrls[id] = TextEditingController(text: m.currentStudents.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Update Capacity'),
      content: SizedBox(
        width: 500,
        child: ListView(
          shrinkWrap: true,
          children: widget.selectedIds.map((id) {
            final m = widget.items.firstWhere((e) => e.id == id);
            return ListTile(
              title: Text(m.className),
              subtitle: Row(
                children: [
                  Expanded(child: TextField(controller: maxCtrls[id], decoration: const InputDecoration(labelText: 'Max'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: curCtrls[id], decoration: const InputDecoration(labelText: 'Current'), keyboardType: TextInputType.number)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final updates = widget.selectedIds.map((id) {
              return {
                'class_id': id,
                'maximum_students': int.tryParse(maxCtrls[id]!.text) ?? 0,
                'current_students': int.tryParse(curCtrls[id]!.text) ?? 0,
              };
            }).toList();
            Navigator.pop(context, updates);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
