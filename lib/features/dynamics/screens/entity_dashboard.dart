import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/entity_config.dart';

class EntityDashboard extends StatefulWidget {
  final String entityKey;
  final String? tenantId;
  
  const EntityDashboard({
    super.key,
    required this.entityKey,
    this.tenantId,
  });

  @override
  State<EntityDashboard> createState() => _EntityDashboardState();
}

class _EntityDashboardState extends State<EntityDashboard> {
  late EntityDefinition entityDef;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    entityDef = EntityConfig.entities[widget.entityKey]!;
    setState(() {
      isLoading = false;
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
        title: Text('${entityDef.name} Dashboard'),
        backgroundColor: entityDef.color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildStatCards(),
            const SizedBox(height: 16),
            buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, color: entityDef.color, size: 32),
              const Text(
                '0',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('Total ${entityDef.pluralName}'),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 32),
              const Text(
                '0',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('Active'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        Card(
          child: InkWell(
            onTap: () => context.go('${entityDef.route}/add'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: entityDef.color),
                const SizedBox(width: 8),
                Text('Add ${entityDef.name}'),
              ],
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () => context.go(entityDef.route),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list, color: entityDef.color),
                const SizedBox(width: 8),
                const Text('View All'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}