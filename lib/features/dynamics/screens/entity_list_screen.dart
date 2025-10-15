import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/entity_config.dart';

class EntityListScreen extends StatefulWidget {
  final String entityKey;
  final String? tenantId;
  
  const EntityListScreen({
    super.key,
    required this.entityKey,
    this.tenantId,
  });

  @override
  State<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  late EntityDefinition entityDef;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  Map<String, String> activeFilters = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    entityDef = EntityConfig.entities[widget.entityKey]!;
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      items = [];
      filteredItems = [];
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredItems = items.where((item) {
        return activeFilters.entries.every((filter) {
          if (filter.value == 'All') return true;
          return item[filter.key]?.toString() == filter.value;
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(entityDef.pluralName),
        backgroundColor: entityDef.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('${entityDef.route}/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          buildFilters(),
          Expanded(child: buildTable()),
        ],
      ),
    );
  }

  Widget buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: entityDef.tableConfig.filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: activeFilters[filter.key] ?? filter.options?.first ?? 'All',
              onChanged: (value) {
                setState(() {
                  activeFilters[filter.key] = value!;
                  applyFilters();
                });
              },
              items: filter.options?.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList() ?? [],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTable() {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(entityDef.icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No ${entityDef.pluralName.toLowerCase()} found'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: entityDef.tableConfig.columns.map((col) {
          return DataColumn(label: Text(col.label));
        }).toList(),
        rows: filteredItems.map((item) {
          return DataRow(
            cells: entityDef.tableConfig.columns.map((col) {
              return DataCell(Text(item[col.key]?.toString() ?? ''));
            }).toList(),
            onSelectChanged: (_) {
              context.go('${entityDef.route}/${item['id']}');
            },
          );
        }).toList(),
      ),
    );
  }
}