import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/entity_config.dart';

class DynamicForm extends StatefulWidget {
  final FormConfig formConfig;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSubmit;

  const DynamicForm({
    super.key,
    required this.formConfig,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.formConfig.fields) {
      _controllers[field.key] = TextEditingController(
        text: widget.initialData?[field.key]?.toString() ?? '',
      );
      _formData[field.key] = widget.initialData?[field.key];
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.formConfig.fields.map(buildField),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(FieldDefinition field) {
    switch (field.type) {
      case 'dropdown':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: field.label),
            value: _formData[field.key]?.toString(),
            items: field.options?.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: (value) => _formData[field.key] = value,
            validator: field.required ? (value) => value == null ? '${field.label} is required' : null : null,
          ),
        );
      
      case 'date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(field.key),
            validator: field.required ? (value) => value?.isEmpty == true ? '${field.label} is required' : null : null,
          ),
        );
      
      default: // text, email, number
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: _controllers[field.key],
            decoration: InputDecoration(labelText: field.label),
            keyboardType: field.type == 'email' ? TextInputType.emailAddress :
                         field.type == 'number' ? TextInputType.number : TextInputType.text,
            validator: field.required ? (value) => value?.isEmpty == true ? '${field.label} is required' : null : null,
            onChanged: (value) => _formData[field.key] = value,
          ),
        );
    }
  }

  Future<void> _selectDate(String fieldKey) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      _controllers[fieldKey]!.text = DateFormat('yyyy-MM-dd').format(date);
      _formData[fieldKey] = date.toIso8601String();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Update form data with controller values
      for (var entry in _controllers.entries) {
        if (entry.value.text.isNotEmpty) {
          _formData[entry.key] = entry.value.text;
        }
      }
      widget.onSubmit(_formData);
    }
  }
}