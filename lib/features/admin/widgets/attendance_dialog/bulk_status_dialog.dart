// lib/features/admin/widgets/attendance_dialog/bulk_status_dialog.dart
import 'package:flutter/material.dart';
import '../../../../services/attendance_service.dart';

class BulkStatusDialog extends StatefulWidget {
  final AttendanceService service;
  const BulkStatusDialog({super.key, required this.service});

  @override
  State<BulkStatusDialog> createState() => _BulkStatusDialogState();
}

class _BulkStatusDialogState extends State<BulkStatusDialog> {
  final _ids = TextEditingController();
  final _updatedBy = TextEditingController();
  final _newStatus = TextEditingController(text: 'absent');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bulk Update Status'),
          TextField(decoration: const InputDecoration(labelText: 'Attendance IDs (comma-separated)'), controller: _ids),
          TextField(decoration: const InputDecoration(labelText: 'Updated By (UUID)'), controller: _updatedBy),
          TextField(decoration: const InputDecoration(labelText: 'New status (present/absent/late/excused/sick/...)'), controller: _newStatus),
          const SizedBox(height: 12),
          Row(children: [
            const Spacer(),
            TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Apply')),
          ]),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final ids = _ids.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final res = await widget.service.bulkUpdateStatus(
        attendanceIds: ids,
        newStatus: _newStatus.text.trim(),
        updatedBy: _updatedBy.text.trim(),
      );
      if (mounted) Navigator.pop(context, res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
