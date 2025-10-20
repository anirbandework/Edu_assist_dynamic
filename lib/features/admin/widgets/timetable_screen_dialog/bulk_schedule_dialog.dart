import 'package:flutter/material.dart';
import '../../../../core/models/timetable_models.dart';
import '../../../../services/timetable_service.dart';

class BulkScheduleDialog extends StatefulWidget {
  const BulkScheduleDialog({
    super.key,
    required this.tenantId,
    required this.classId,
    required this.academicYear,
    required this.api,
  });

  final UUID tenantId;
  final UUID classId;
  final String academicYear;
  final TimetableService api;

  @override
  State<BulkScheduleDialog> createState() => _BulkScheduleDialogState();
}

class _BulkScheduleDialogState extends State<BulkScheduleDialog> {
  String mode = "create"; // create | update | delete

  // Row structure for lightweight editing; adapt as needed
  final List<Map<String, dynamic>> rows = [];

  void _addRow() {
    setState(() {
      rows.add({
        "schedule_entry_id": null,
        "class_timetable_id": widget.classId,
        "period_id": null,         // required for create
        "day_of_week": "monday",   // required for create
        "subject_id": null,
        "subject_name": "",
        "teacher_timetable_id": null,
        "teacher_name": "",
        "room_number": "",
        "notes": "",
      });
    });
  }

  Future<void> _submit() async {
    try {
      if (mode == "create") {
        final payload = BulkScheduleCreate(
          tenantId: widget.tenantId,
          scheduleEntries: rows.map((r) => {
            "class_timetable_id": r["class_timetable_id"],
            "period_id": r["period_id"],
            "day_of_week": r["day_of_week"], // lowercase
            "subject_id": r["subject_id"],
            "subject_name": r["subject_name"],
            "teacher_timetable_id": r["teacher_timetable_id"],
            "teacher_name": r["teacher_name"],
            "room_number": r["room_number"],
            "notes": r["notes"],
          }).toList(),
        );
        await widget.api.bulkCreateSchedule(payload);
      } else if (mode == "update") {
        final payload = BulkScheduleUpdate(rows.where((r) => r["schedule_entry_id"] != null).map((r) => {
          "schedule_entry_id": r["schedule_entry_id"],
          "subject_id": r["subject_id"],
          "subject_name": r["subject_name"],
          "teacher_timetable_id": r["teacher_timetable_id"],
          "teacher_name": r["teacher_name"],
          "room_number": r["room_number"],
          "notes": r["notes"],
        }).toList());
        await widget.api.bulkUpdateSchedule(payload);
      } else {
        final ids = rows.map((r) => r["schedule_entry_id"] as String?).whereType<String>().toList();
        await widget.api.bulkDeleteSchedule(ids, hardDelete: false);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text("Bulk Schedule Editor")),
          DropdownButton<String>(
            value: mode,
            items: const [
              DropdownMenuItem(value: "create", child: Text("Create")),
              DropdownMenuItem(value: "update", child: Text("Update")),
              DropdownMenuItem(value: "delete", child: Text("Delete")),
            ],
            onChanged: (v) => setState(() => mode = v!),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              ElevatedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text("Add row")),
              const SizedBox(width: 8),
              Text("${rows.length} row(s)"),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 360,
              child: ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final r = rows[i];
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Day (monday..sunday)"),
                          initialValue: r["day_of_week"] ?? "monday",
                          onChanged: (v) => r["day_of_week"] = v.toLowerCase(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Period ID (UUID)"),
                          initialValue: r["period_id"],
                          onChanged: (v) => r["period_id"] = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Subject name"),
                          initialValue: r["subject_name"],
                          onChanged: (v) => r["subject_name"] = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Teacher name"),
                          initialValue: r["teacher_name"],
                          onChanged: (v) => r["teacher_name"] = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Room"),
                          initialValue: r["room_number"],
                          onChanged: (v) => r["room_number"] = v,
                        ),
                      ),
                      IconButton(onPressed: () => setState(() => rows.removeAt(i)), icon: const Icon(Icons.delete_outline)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Close")),
        ElevatedButton(onPressed: rows.isEmpty ? null : _submit, child: const Text("Submit")),
      ],
    );
  }
}
