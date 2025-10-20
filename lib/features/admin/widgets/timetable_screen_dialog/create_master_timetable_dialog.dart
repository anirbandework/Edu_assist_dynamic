import 'package:flutter/material.dart';
import '../../../../core/models/timetable_models.dart';
import '../../../../services/timetable_service.dart';

class CreateMasterTimetableDialog extends StatefulWidget {
  const CreateMasterTimetableDialog({
    super.key,
    required this.tenantId,
    required this.userId,
    required this.academicYear,
    required this.api,
  });

  final UUID tenantId;
  final UUID userId;
  final String academicYear;
  final TimetableService api;

  @override
  State<CreateMasterTimetableDialog> createState() => _CreateMasterTimetableDialogState();
}

class _CreateMasterTimetableDialogState extends State<CreateMasterTimetableDialog> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String timetableName = "";
  String? description;
  String? term;

  DateTime effectiveFrom = DateTime.now();
  DateTime? effectiveUntil;

  String schoolStartTime = "09:00:00";
  String schoolEndTime = "16:00:00";

  int totalPeriodsPerDay = 8;
  int periodDuration = 45;
  int breakDuration = 15;
  int lunchDuration = 60;

  final Set<DayOfWeek> workingDays = {
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
    DayOfWeek.friday,
  };

  bool autoGeneratePeriods = true;
  bool submitting = false;

  Future<void> _pickDate(BuildContext ctx, {required bool from}) async {
    final initial = from ? effectiveFrom : (effectiveUntil ?? effectiveFrom.add(const Duration(days: 90)));
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (from) {
          effectiveFrom = picked;
          if (effectiveUntil != null && effectiveUntil!.isBefore(effectiveFrom)) {
            effectiveUntil = effectiveFrom;
          }
        } else {
          effectiveUntil = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final payload = MasterTimetableCreate(
      tenantId: widget.tenantId,
      createdBy: widget.userId,
      timetableName: timetableName,
      description: description,
      academicYear: widget.academicYear,
      term: term,
      effectiveFrom: effectiveFrom.toIso8601String().substring(0, 10),
      effectiveUntil: effectiveUntil?.toIso8601String().substring(0, 10),
      totalPeriodsPerDay: totalPeriodsPerDay,
      schoolStartTime: schoolStartTime,
      schoolEndTime: schoolEndTime,
      periodDuration: periodDuration,
      breakDuration: breakDuration,
      lunchDuration: lunchDuration,
      workingDays: workingDays.toList(),
      autoGeneratePeriods: autoGeneratePeriods,
    );

    setState(() => submitting = true);
    try {
      final res = await widget.api.createMaster(payload);
      if (mounted) Navigator.of(context).pop(res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Master Timetable"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Basic info
              TextFormField(
                decoration: const InputDecoration(labelText: "Timetable name"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                onSaved: (v) => timetableName = v!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (v) => description = v?.trim().isEmpty == true ? null : v?.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Term (optional)"),
                onSaved: (v) => term = v?.trim().isEmpty == true ? null : v?.trim(),
              ),

              const SizedBox(height: 12),
              // Dates
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Effective from"),
                      subtitle: Text(effectiveFrom.toIso8601String().substring(0, 10)),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () => _pickDate(context, from: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Effective until"),
                      subtitle: Text(effectiveUntil == null
                          ? "—"
                          : effectiveUntil!.toIso8601String().substring(0, 10)),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () => _pickDate(context, from: false),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Times and durations
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: schoolStartTime,
                      decoration: const InputDecoration(labelText: "School start time (HH:mm:ss)"),
                      onSaved: (v) => schoolStartTime = v!.trim(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: schoolEndTime,
                      decoration: const InputDecoration(labelText: "School end time (HH:mm:ss)"),
                      onSaved: (v) => schoolEndTime = v!.trim(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "$totalPeriodsPerDay",
                      decoration: const InputDecoration(labelText: "Total periods/day"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => totalPeriodsPerDay = int.tryParse(v ?? "") ?? 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: "$periodDuration",
                      decoration: const InputDecoration(labelText: "Period duration (min)"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => periodDuration = int.tryParse(v ?? "") ?? 45,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "$breakDuration",
                      decoration: const InputDecoration(labelText: "Break duration (min)"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => breakDuration = int.tryParse(v ?? "") ?? 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: "$lunchDuration",
                      decoration: const InputDecoration(labelText: "Lunch duration (min)"),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => lunchDuration = int.tryParse(v ?? "") ?? 60,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Working days
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  children: DayOfWeek.values.map((d) {
                    final selected = workingDays.contains(d);
                    return FilterChip(
                      label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        v ? workingDays.add(d) : workingDays.remove(d);
                      }),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),
              SwitchListTile(
                value: autoGeneratePeriods,
                onChanged: (v) => setState(() => autoGeneratePeriods = v),
                title: const Text("Auto-generate periods"),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: submitting ? null : () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(onPressed: submitting ? null : _submit, child: const Text("Create")),
      ],
    );
  }
}
