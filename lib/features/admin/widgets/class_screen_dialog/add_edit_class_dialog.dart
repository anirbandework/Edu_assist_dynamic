import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/models/class_model.dart';

class AddEditClassDialog extends StatefulWidget {
  final ClassModel? initial;
  final String tenantId;
  const AddEditClassDialog({super.key, this.initial, required this.tenantId});

  @override
  State<AddEditClassDialog> createState() => _AddEditClassDialogState();
}

class _AddEditClassDialogState extends State<AddEditClassDialog> {
  final _form = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController grade;
  late TextEditingController section;
  late TextEditingController year;
  late TextEditingController max;
  late TextEditingController current;
  late TextEditingController classroom;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    name = TextEditingController(text: i?.className ?? '');
    grade = TextEditingController(text: i?.gradeLevel.toString() ?? '');
    section = TextEditingController(text: i?.section ?? '');
    year = TextEditingController(text: i?.academicYear ?? '');
    max = TextEditingController(text: i?.maximumStudents.toString() ?? '40');
    current = TextEditingController(text: i?.currentStudents.toString() ?? '0');
    classroom = TextEditingController(text: i?.classroom ?? '');
    isActive = i?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Create Class' : 'Edit Class'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Class Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: grade,
                decoration: const InputDecoration(labelText: 'Grade Level'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Number' : null,
              ),
              TextFormField(
                controller: section,
                decoration: const InputDecoration(labelText: 'Section'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: year,
                decoration: const InputDecoration(labelText: 'Academic Year (e.g., 2025-26)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: max,
                decoration: const InputDecoration(labelText: 'Maximum Students'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Number' : null,
              ),
              TextFormField(
                controller: current,
                decoration: const InputDecoration(labelText: 'Current Students'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Number' : null,
              ),
              TextFormField(
                controller: classroom,
                decoration: const InputDecoration(labelText: 'Classroom (optional)'),
              ),
              SwitchListTile(
                value: isActive,
                onChanged: (v) => setState(() => isActive = v),
                title: const Text('Active'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              final m = ClassModel(
                id: widget.initial?.id ?? '',
                tenantId: widget.tenantId,
                className: name.text.trim(),
                gradeLevel: int.parse(grade.text),
                section: section.text.trim(),
                academicYear: year.text.trim(),
                maximumStudents: int.parse(max.text),
                currentStudents: int.parse(current.text),
                classroom: classroom.text.trim().isEmpty ? null : classroom.text.trim(),
                isActive: isActive,
              );
              Navigator.pop(context, m);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
