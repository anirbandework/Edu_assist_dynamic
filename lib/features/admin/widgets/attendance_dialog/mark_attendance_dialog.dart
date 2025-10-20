// lib/features/admin/widgets/attendance_dialog/mark_attendance_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/models/attendance_models.dart';
import '../../../../services/attendance_service.dart';

class MarkAttendanceDialog extends StatefulWidget {
  final AttendanceService service;
  final String authorityId;
  const MarkAttendanceDialog({super.key, required this.service, required this.authorityId});

  @override
  State<MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<MarkAttendanceDialog> {
  final _form = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _classId = TextEditingController();
  final _subject = TextEditingController();
  final _remarks = TextEditingController();
  DateTime _date = DateTime.now();
  AttendanceType _type = AttendanceType.daily;
  AttendanceStatus _status = AttendanceStatus.present;
  int? _period;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final dialogWidth = context.responsive(ResponsiveSize.dialogWidth) ?? context.screenWidth - 32;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mark Attendance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ResponsiveRow(
                  spacing: 12,
                  children: [
                    _text('User ID', _userId),
                    _text('Class ID (optional)', _classId),
                  ],
                ),
                const SizedBox(height: 8),
                ResponsiveRow(
                  spacing: 12,
                  children: [
                    _dateField(context),
                    _dropdown<AttendanceType>('Type', _type, AttendanceType.values, (v) => setState(() => _type = v)),
                    _dropdown<AttendanceStatus>('Status', _status, AttendanceStatus.values, (v) => setState(() => _status = v)),
                  ],
                ),
                const SizedBox(height: 8),
                ResponsiveRow(
                  spacing: 12,
                  children: [
                    _text('Subject (optional)', _subject),
                    _number('Period (optional)', (v) => _period = v),
                  ],
                ),
                const SizedBox(height: 8),
                _multiline('Remarks (optional)', _remarks),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(String label, TextEditingController c) => TextFormField(
    decoration: InputDecoration(labelText: label),
    controller: c,
    validator: (v) => (v == null || v.isEmpty) && label.contains('User') ? 'Required' : null,
  );

  Widget _number(String label, void Function(int?) onSaved) => TextFormField(
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.number,
    onSaved: (v) => onSaved(int.tryParse(v ?? '')),
  );

  Widget _multiline(String label, TextEditingController c) => TextFormField(
    decoration: InputDecoration(labelText: label),
    controller: c,
    minLines: 2,
    maxLines: 3,
  );

  Widget _dateField(BuildContext context) => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDate: _date,
      );
      if (picked != null) setState(() => _date = picked);
    },
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Date'),
      child: Text(_date.toIso8601String().split('T').first),
    ),
  );

  Widget _dropdown<T>(String label, T value, List<T> items, void Function(T) onChanged) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last))).toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    setState(() => _loading = true);
    try {
      final body = {
        'user_id': _userId.text.trim(),
        'user_type': UserType.student.name, // change via UX as needed
        'class_id': _classId.text.isEmpty ? null : _classId.text.trim(),
        'attendance_date': _date.toIso8601String().split('T').first,
        'attendance_type': _type.name,
        'status': _status.name,
        'period_number': _period,
        'subject_name': _subject.text.isEmpty ? null : _subject.text.trim(),
      }..removeWhere((k, v) => v == null);

      await widget.service.markStudent(
        markedBy: widget.authorityId,
        markedByType: UserType.school_authority,
        body: body,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
