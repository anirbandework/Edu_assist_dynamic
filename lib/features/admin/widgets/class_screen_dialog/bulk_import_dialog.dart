import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BulkImportDialog extends StatefulWidget {
  const BulkImportDialog({super.key});
  @override
  State<BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends State<BulkImportDialog> {
  FilePickerResult? picked;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      withReadStream: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (!mounted) return;
    if (res != null && res.files.isNotEmpty) {
      setState(() => picked = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = picked?.files.single.name;
    return AlertDialog(
      title: const Text('Bulk Import CSV'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Upload a .csv with headers: '
            'class_name,grade_level,section,academic_year,maximum_students,'
            'current_students,classroom,is_active',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.file_present),
            label: Text(fileName == null ? 'Choose CSV' : fileName),
            onPressed: _pick,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: picked == null
              ? null
              : () => Navigator.pop<FilePickerResult>(context, picked),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
