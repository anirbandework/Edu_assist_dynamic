// lib/features/admin/widgets/attendance_dialog/class_by_date_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/attendance_service.dart';
import '../../../../core/models/attendance_models.dart';

// Reuse your ClassModel and ClassApi (paste.txt) by importing the file where you placed them.
// If ClassApi is in lib/features/admin/services/class_api.dart, update the import accordingly.
import '../../../../core/models/class_model.dart'; // <-- adjust to your actual path
import '../../../../services/class_service.dart'; // <-- adjust to your actual path

class ClassByDateDialog extends StatefulWidget {
  final AttendanceService service;
  final String? tenantId; // optional, try to read from query/session if null
  final DateTime? initialDate;

  const ClassByDateDialog({
    super.key,
    required this.service,
    this.tenantId,
    this.initialDate,
  });

  @override
  State<ClassByDateDialog> createState() => _ClassByDateDialogState();
}

class _ClassByDateDialogState extends State<ClassByDateDialog> {
  final _periodCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;
  bool _loadingClasses = false;

  // Data
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<AttendanceRecord> _rows = [];

  late final ClassApi _classApi;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    _classApi = ClassApi(baseUrl: AppConstants.apiBaseUrl);
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    if (widget.tenantId == null || widget.tenantId!.isEmpty) return;
    setState(() {
      _loadingClasses = true;
      _classes = [];
      _selectedClass = null;
    });
    try {
      // Get first page with a large page_size to avoid pagination for dialog selection
      final body = await _classApi.getPaginated(
        tenantId: widget.tenantId,
        page: 1,
        pageSize: 200,
        isActive: true,
      );
      final list = ClassModel.listFromPaginated(body);
      setState(() {
        _classes = list;
        if (_classes.isNotEmpty) _selectedClass = _classes.first;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingClasses = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _loadAttendance() async {
    if (_selectedClass == null) return;
    final period = int.tryParse(_periodCtrl.text.trim());
    setState(() {
      _loading = true;
      _rows = [];
    });
    try {
      final rows = await widget.service.getClassByDate(
        classId: _selectedClass!.id,
        attendanceDate: _date,
        periodNumber: period,
      );
      setState(() => _rows = rows);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = context.responsive(ResponsiveSize.dialogWidth) ?? (context.screenWidth - 32);
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: context.screenHeight * 0.9),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Icon(Icons.people_alt_outlined),
                const SizedBox(width: 8),
                Text('Class attendance by date', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 12),

              // Filters row
              ResponsiveRow(
                spacing: 12,
                children: [
                  // Tenant locked info (optional)
                  Expanded(
                    child: InkWell(
                      onTap: null,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tenant'),
                        child: Text(widget.tenantId ?? '-'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _loadingClasses
                        ? const LinearProgressIndicator(minHeight: 24)
                        : DropdownButtonFormField<ClassModel>(
                            value: _selectedClass,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Class'),
                            items: _classes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('${c.className} • Grade ${c.gradeLevel}${c.section.isNotEmpty ? ' - ${c.section}' : ''}'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _selectedClass = v),
                          ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(_date.toIso8601String().split('T').first),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _periodCtrl,
                      decoration: const InputDecoration(labelText: 'Period (optional)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: (_selectedClass == null || _loading) ? null : _loadAttendance,
                    icon: const Icon(Icons.search),
                    label: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Results
              Expanded(
                child: _rows.isEmpty
                    ? const Center(child: Text('No records'))
                    : Scrollbar(
                        child: ListView.separated(
                          itemCount: _rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final r = _rows[i];
                            return ListTile(
                              dense: true,
                              title: Text('${r.userId} • ${r.subjectName ?? '-'}'),
                              subtitle: Text('${r.status.name} • ${r.attendanceType.name} • Period ${r.periodNumber ?? '-'}'),
                              trailing: Text(r.attendanceDate.toIso8601String().split('T').first),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
