import 'package:flutter/material.dart';

class BulkUpdateStatusDialog extends StatelessWidget {
  const BulkUpdateStatusDialog({super.key});
  @override
  Widget build(BuildContext context) {
    bool active = true;
    return StatefulBuilder(
      builder: (_, setState) => AlertDialog(
        title: const Text('Bulk Status'),
        content: SwitchListTile(
          value: active,
          onChanged: (v) => setState(() => active = v),
          title: Text(active ? 'Set Active' : 'Set Inactive'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop<bool>(context, active), child: const Text('Apply')),
        ],
      ),
    );
  }
}
