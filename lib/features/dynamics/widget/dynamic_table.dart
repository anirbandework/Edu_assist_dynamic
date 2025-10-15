import 'package:flutter/material.dart';
import '../../../core/config/entity_config.dart';

class DynamicTable extends StatelessWidget {
  final List<ColumnDefinition> columns;
  final List<dynamic> data;
  final Function(dynamic)? onRowTap;

  const DynamicTable({
    super.key,
    required this.columns,
    required this.data,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(
          label: Text(col.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        )).toList(),
        rows: data.map((item) => DataRow(
          onSelectChanged: onRowTap != null ? (_) => onRowTap!(item) : null,
          cells: columns.map((col) => DataCell(
            Text(_formatValue(item[col.key])),
          )).toList(),
        )).toList(),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    return value.toString();
  }
}
