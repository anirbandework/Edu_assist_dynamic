// lib/features/admin/widgets/tenant_create_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';

class TenantCreateDialog extends StatefulWidget {
  final VoidCallback onTenantCreated;

  const TenantCreateDialog({
    super.key,
    required this.onTenantCreated,
  });

  @override
  State<TenantCreateDialog> createState() => _TenantCreateDialogState();
}

class _TenantCreateDialogState extends State<TenantCreateDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isLoading = false;

  // Basic Info
  final _schoolNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _principalNameController = TextEditingController();
  String _schoolType = 'K-12';
  String _languageOfInstruction = 'English';

  // Academic Info
  final _establishedYearController = TextEditingController();
  final _accreditationController = TextEditingController();
  DateTime? _academicYearStart;
  DateTime? _academicYearEnd;
  final List<String> _selectedGradeLevels = [];

  // Capacity & Financial
  final _maximumCapacityController = TextEditingController();
  final _currentEnrollmentController = TextEditingController();
  final _totalStudentsController = TextEditingController();
  final _totalTeachersController = TextEditingController();
  final _totalStaffController = TextEditingController();
  final _annualTuitionController = TextEditingController();
  final _registrationFeeController = TextEditingController();

  final List<String> _schoolTypes = ['K-12', 'Elementary', 'Middle School', 'High School', 'University', 'Preschool'];
  final List<String> _languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Marathi', 'Bengali', 'Other'];
  final List<String> _gradeLevels = ['Pre-K', 'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set default dates
    _academicYearStart = DateTime(DateTime.now().year, 6, 1); // June 1st
    _academicYearEnd = DateTime(DateTime.now().year + 1, 5, 31); // May 31st next year
  }

  @override
  void dispose() {
    _tabController.dispose();
    _schoolNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _principalNameController.dispose();
    _establishedYearController.dispose();
    _accreditationController.dispose();
    _maximumCapacityController.dispose();
    _currentEnrollmentController.dispose();
    _totalStudentsController.dispose();
    _totalTeachersController.dispose();
    _totalStaffController.dispose();
    _annualTuitionController.dispose();
    _registrationFeeController.dispose();
    super.dispose();
  }

  Future<void> _createTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tenantData = {
      'school_name': _schoolNameController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'principal_name': _principalNameController.text.trim(),
      'school_type': _schoolType,
      'language_of_instruction': _languageOfInstruction,
      'established_year': int.tryParse(_establishedYearController.text) ?? 0,
      'accreditation': _accreditationController.text.trim(),
      'academic_year_start': _academicYearStart?.toIso8601String(),
      'academic_year_end': _academicYearEnd?.toIso8601String(),
      'grade_levels': _selectedGradeLevels,
      'maximum_capacity': int.tryParse(_maximumCapacityController.text) ?? 0,
      'current_enrollment': int.tryParse(_currentEnrollmentController.text) ?? 0,
      'total_students': int.tryParse(_totalStudentsController.text) ?? 0,
      'total_teachers': int.tryParse(_totalTeachersController.text) ?? 0,
      'total_staff': int.tryParse(_totalStaffController.text) ?? 0,
      'annual_tuition': double.tryParse(_annualTuitionController.text) ?? 0.0,
      'registration_fee': double.tryParse(_registrationFeeController.text) ?? 0.0,
      'is_active': true,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/tenants/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tenantData),
      );

      if (response.statusCode == 200) {
        widget.onTenantCreated();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('School "${_schoolNameController.text}" created successfully'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to create school');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.school, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Add New School',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryGreen,
              tabs: const [
                Tab(text: 'Basic Info'),
                Tab(text: 'Academic'),
                Tab(text: 'Capacity & Finance'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildAcademicTab(),
                    _buildCapacityFinanceTab(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createTenant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create School'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _schoolNameController,
                  decoration: const InputDecoration(
                    labelText: 'School Name *',
                    hintText: 'Enter school name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'School name is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _schoolType,
                  decoration: const InputDecoration(
                    labelText: 'School Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _schoolTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _schoolType = value!),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              hintText: 'Enter complete address',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '+91 98765 43210',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Phone number is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'school@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _principalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Principal Name *',
                    hintText: 'Enter principal name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Principal name is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _languageOfInstruction,
                  decoration: const InputDecoration(
                    labelText: 'Language of Instruction',
                    border: OutlineInputBorder(),
                  ),
                  items: _languages.map((lang) {
                    return DropdownMenuItem(value: lang, child: Text(lang));
                  }).toList(),
                  onChanged: (value) => setState(() => _languageOfInstruction = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _establishedYearController,
                  decoration: const InputDecoration(
                    labelText: 'Established Year',
                    hintText: '1995',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _accreditationController,
                  decoration: const InputDecoration(
                    labelText: 'Accreditation',
                    hintText: 'CBSE, ICSE, IB, etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _academicYearStart ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _academicYearStart = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Academic Year Start',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _academicYearStart != null
                          ? '${_academicYearStart!.day}/${_academicYearStart!.month}/${_academicYearStart!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _academicYearEnd ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _academicYearEnd = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Academic Year End',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _academicYearEnd != null
                          ? '${_academicYearEnd!.day}/${_academicYearEnd!.month}/${_academicYearEnd!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Grade Levels Offered',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _gradeLevels.map((grade) {
              final isSelected = _selectedGradeLevels.contains(grade);
              return FilterChip(
                label: Text('Grade $grade'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGradeLevels.add(grade);
                    } else {
                      _selectedGradeLevels.remove(grade);
                    }
                  });
                },
                selectedColor: AppTheme.lightGreen,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityFinanceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capacity Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maximumCapacityController,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Capacity',
                    hintText: '1000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _currentEnrollmentController,
                  decoration: const InputDecoration(
                    labelText: 'Current Enrollment',
                    hintText: '850',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _totalStudentsController,
                  decoration: const InputDecoration(
                    labelText: 'Total Students',
                    hintText: '850',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _totalTeachersController,
                  decoration: const InputDecoration(
                    labelText: 'Total Teachers',
                    hintText: '45',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _totalStaffController,
                  decoration: const InputDecoration(
                    labelText: 'Total Staff',
                    hintText: '15',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Financial Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _annualTuitionController,
                  decoration: const InputDecoration(
                    labelText: 'Annual Tuition (₹)',
                    hintText: '50000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _registrationFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Fee (₹)',
                    hintText: '5000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
