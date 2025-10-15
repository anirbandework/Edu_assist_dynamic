import 'package:flutter/material.dart';

// Base configuration classes
class EntityDefinition {
  final String name;
  final String pluralName;
  final IconData icon;
  final Color color;
  final String route;
  final String apiEndpoint;
  final TableConfig tableConfig;
  final FormConfig formConfig;
  final DashboardConfig dashboardConfig;
  final ChartConfigs chartConfigs;

  EntityDefinition({
    required this.name,
    required this.pluralName,
    required this.icon,
    required this.color,
    required this.route,
    required this.apiEndpoint,
    required this.tableConfig,
    required this.formConfig,
    required this.dashboardConfig,
    required this.chartConfigs,
  });
}

abstract class TableConfig {
  List<ColumnDefinition> get columns;
  List<FilterDefinition> get filters;
}

abstract class FormConfig {
  List<FieldDefinition> get fields;
}

abstract class DashboardConfig {}

abstract class ChartConfigs {}

class ColumnDefinition {
  final String key;
  final String label;
  final double flex;

  const ColumnDefinition({
    required this.key,
    required this.label,
    this.flex = 1.0,
  });
}

class FilterDefinition {
  final String key;
  final String label;
  final String type;
  final List<String>? options;

  const FilterDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });
}

class FieldDefinition {
  final String key;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
  });
}

class EntityConfig {
  static final Map<String, EntityDefinition> entities = {
    'student': EntityDefinition(
      name: 'Student',
      pluralName: 'Students',
      icon: Icons.person,
      color: Colors.blue,
      route: '/students',
      apiEndpoint: '/students',
      tableConfig: StudentTableConfig(),
      formConfig: StudentFormConfig(),
      dashboardConfig: StudentDashboardConfig(),
      chartConfigs: StudentChartConfigs(),
    ),
    
    'teacher': EntityDefinition(
      name: 'Teacher',
      pluralName: 'Teachers', 
      icon: Icons.person_2,
      color: Colors.green,
      route: '/teachers',
      apiEndpoint: '/teachers',
      tableConfig: TeacherTableConfig(),
      formConfig: TeacherFormConfig(),
      dashboardConfig: TeacherDashboardConfig(),
      chartConfigs: TeacherChartConfigs(),
    ),

    'worker': EntityDefinition(
      name: 'Worker',
      pluralName: 'Workers',
      icon: Icons.engineering,
      color: Colors.indigo,
      route: '/workers', 
      apiEndpoint: '/workers',
      tableConfig: WorkerTableConfig(),
      formConfig: WorkerFormConfig(),
      dashboardConfig: WorkerDashboardConfig(),
      chartConfigs: WorkerChartConfigs(),
    ),
  };
}

// Each entity has its own configuration classes:
class StudentTableConfig extends TableConfig {
  @override
  List<ColumnDefinition> get columns => [
    const ColumnDefinition(key: 'name', label: 'Name', flex: 2.0),
    const ColumnDefinition(key: 'email', label: 'Email', flex: 2.0),
    const ColumnDefinition(key: 'gradeLevel', label: 'Grade', flex: 1.0),
    const ColumnDefinition(key: 'section', label: 'Section', flex: 1.0),
    const ColumnDefinition(key: 'status', label: 'Status', flex: 1.0),
  ];
  
  @override
  List<FilterDefinition> get filters => [
    const FilterDefinition(
      key: 'gradeLevel',
      label: 'Grade',
      type: 'dropdown',
      options: ['All', 'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
    ),
  ];
}

class StudentFormConfig extends FormConfig {
  @override
  List<FieldDefinition> get fields => [
    const FieldDefinition(key: 'firstName', label: 'First Name', type: 'text', required: true),
    const FieldDefinition(key: 'lastName', label: 'Last Name', type: 'text', required: true),
    const FieldDefinition(key: 'email', label: 'Email', type: 'email', required: true),
    const FieldDefinition(
      key: 'gradeLevel',
      label: 'Grade Level',
      type: 'dropdown',
      required: true,
      options: ['K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
    ),
  ];
}

// Teacher configurations
class TeacherTableConfig extends TableConfig {
  @override
  List<ColumnDefinition> get columns => [
    const ColumnDefinition(key: 'name', label: 'Name', flex: 2.0),
    const ColumnDefinition(key: 'email', label: 'Email', flex: 2.0),
    const ColumnDefinition(key: 'subject', label: 'Subject', flex: 1.5),
    const ColumnDefinition(key: 'department', label: 'Department', flex: 1.5),
    const ColumnDefinition(key: 'status', label: 'Status', flex: 1.0),
  ];
  
  @override
  List<FilterDefinition> get filters => [
    const FilterDefinition(
      key: 'department',
      label: 'Department',
      type: 'dropdown',
      options: ['All', 'Math', 'Science', 'English', 'History', 'Art'],
    ),
  ];
}

class TeacherFormConfig extends FormConfig {
  @override
  List<FieldDefinition> get fields => [
    const FieldDefinition(key: 'firstName', label: 'First Name', type: 'text', required: true),
    const FieldDefinition(key: 'lastName', label: 'Last Name', type: 'text', required: true),
    const FieldDefinition(key: 'email', label: 'Email', type: 'email', required: true),
    const FieldDefinition(
      key: 'subject',
      label: 'Subject',
      type: 'dropdown',
      required: true,
      options: ['Math', 'Science', 'English', 'History', 'Art'],
    ),
  ];
}

// Worker configurations
class WorkerTableConfig extends TableConfig {
  @override
  List<ColumnDefinition> get columns => [
    const ColumnDefinition(key: 'name', label: 'Name', flex: 2.0),
    const ColumnDefinition(key: 'email', label: 'Email', flex: 2.0),
    const ColumnDefinition(key: 'role', label: 'Role', flex: 1.5),
    const ColumnDefinition(key: 'department', label: 'Department', flex: 1.5),
    const ColumnDefinition(key: 'status', label: 'Status', flex: 1.0),
  ];
  
  @override
  List<FilterDefinition> get filters => [
    const FilterDefinition(
      key: 'role',
      label: 'Role',
      type: 'dropdown',
      options: ['All', 'Janitor', 'Security', 'Maintenance', 'Admin'],
    ),
  ];
}

class WorkerFormConfig extends FormConfig {
  @override
  List<FieldDefinition> get fields => [
    const FieldDefinition(key: 'firstName', label: 'First Name', type: 'text', required: true),
    const FieldDefinition(key: 'lastName', label: 'Last Name', type: 'text', required: true),
    const FieldDefinition(key: 'email', label: 'Email', type: 'email', required: true),
    const FieldDefinition(
      key: 'role',
      label: 'Role',
      type: 'dropdown',
      required: true,
      options: ['Janitor', 'Security', 'Maintenance', 'Admin'],
    ),
  ];
}

// Dashboard and Chart configurations
class StudentDashboardConfig extends DashboardConfig {}
class TeacherDashboardConfig extends DashboardConfig {}
class WorkerDashboardConfig extends DashboardConfig {}

class StudentChartConfigs extends ChartConfigs {}
class TeacherChartConfigs extends ChartConfigs {}
class WorkerChartConfigs extends ChartConfigs {}
