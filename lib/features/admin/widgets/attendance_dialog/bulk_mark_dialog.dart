// lib/features/admin/widgets/attendance_dialog/bulk_mark_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/models/attendance_models.dart';
import '../../../../services/attendance_service.dart';

class BulkMarkDialog extends StatefulWidget {
  final AttendanceService service;
  final String tenantId;
  const BulkMarkDialog({super.key, required this.service, required this.tenantId});

  @override
  State<BulkMarkDialog> createState() => _BulkMarkDialogState();
}

class _BulkMarkDialogState extends State<BulkMarkDialog> {
  final _json = TextEditingController(text: '''
[
  {
    "user_id": "uuid-1",
    "user_type": "student",
    "class_id": "class-uuid",
    "attendance_date": "${DateTime.now().toIso8601String().split('T').first}",
    "attendance_type": "daily",
    "status": "present"
  }
]
''');

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bulk Mark Attendance'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _json,
            minLines: 10,
            maxLines: 18,
            decoration: const InputDecoration(hintText: 'Paste JSON array of attendance_records'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Upload'),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final decoded = jsonDecode(_json.text);
      final list = List<Map<String, dynamic>>.from(decoded);

      final res = await widget.service.bulkMark(tenantId: widget.tenantId, records: list);
      if (mounted) Navigator.pop(context, res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
