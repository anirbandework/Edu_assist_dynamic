// lib/features/admin/widgets/attendance_dialog/bulk_approve_dialog.dart
import 'package:flutter/material.dart';
import '../../../../services/attendance_service.dart';

class BulkApproveDialog extends StatefulWidget {
  final AttendanceService service;
  const BulkApproveDialog({super.key, required this.service});

  @override
  State<BulkApproveDialog> createState() => _BulkApproveDialogState();
}

class _BulkApproveDialogState extends State<BulkApproveDialog> {
  final _ids = TextEditingController();
  final _approvedBy = TextEditingController();
  final _remarks = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Bulk Approve Absences'),
          TextField(decoration: const InputDecoration(labelText: 'Attendance IDs (comma-separated)'), controller: _ids),
          TextField(decoration: const InputDecoration(labelText: 'Approved By (UUID)'), controller: _approvedBy),
          TextField(decoration: const InputDecoration(labelText: 'Approval Remarks (optional)'), controller: _remarks),
          const SizedBox(height: 12),
          Row(children: [
            const Spacer(),
            TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Approve')),
          ]),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final ids = _ids.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final res = await widget.service.bulkApproveAbsences(
        attendanceIds: ids,
        approvedBy: _approvedBy.text.trim(),
        approvalRemarks: _remarks.text.trim().isEmpty ? null : _remarks.text.trim(),
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
