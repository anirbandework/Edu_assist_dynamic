// lib/features/admin/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/attendance_service.dart';
import '../../../core/models/attendance_models.dart';
import '../widgets/attendance_dialog/mark_attendance_dialog.dart';
import '../widgets/attendance_dialog/bulk_mark_dialog.dart';
import '../widgets/attendance_dialog/bulk_status_dialog.dart';
import '../widgets/attendance_dialog/bulk_approve_dialog.dart';
import '../widgets/attendance_dialog/class_by_date_dialog.dart';

class AttendanceScreen extends StatefulWidget {
  final AttendanceService service;
  final String tenantId;
  final String authorityUserId;
  const AttendanceScreen({super.key, required this.service, required this.tenantId, required this.authorityUserId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  bool _loading = false;
  Map<String, dynamic>? _dashboard;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final stats = await widget.service.getDashboard(tenantId: widget.tenantId);
      setState(() => _dashboard = stats);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 12),
          _toolbar(context),
          const SizedBox(height: 12),
          _tabs(context),
          const SizedBox(height: 12),
          Expanded(child: _tabViews(context)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text('Attendance', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (_loading) const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return ResponsiveRow(
      spacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => _openMarkDialog(context),
          icon: const Icon(Icons.check),
          label: const Text('Mark'),
        ),
        ElevatedButton.icon(
          onPressed: () => _openBulkMark(context),
          icon: const Icon(Icons.playlist_add),
          label: const Text('Bulk Mark'),
        ),
        OutlinedButton.icon(
          onPressed: () => _openBulkStatus(context),
          icon: const Icon(Icons.sync),
          label: const Text('Bulk Status'),
        ),
        OutlinedButton.icon(
          onPressed: () => _openBulkApprove(context),
          icon: const Icon(Icons.verified),
          label: const Text('Approve Absences'),
        ),
        const Spacer(),
        IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh)),
      ],
    );
  }

  Widget _tabs(BuildContext context) {
    return Container(
      decoration: AppTheme.compactCardDecoration,
      child: TabBar(
        controller: _tab,
        tabs: const [Tab(text: 'Daily'), Tab(text: 'Period'), Tab(text: 'Analytics')],
      ),
    );
  }

  Widget _tabViews(BuildContext context) {
    return TabBarView(
      controller: _tab,
      children: [
        _dailyTab(context),
        _periodTab(context),
        _analyticsTab(context),
      ],
    );
  }

  Widget _dailyTab(BuildContext context) {
    // Minimal: action to open class-by-date dialog
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _openClassByDate(context),
        icon: const Icon(Icons.people_outline),
        label: const Text('Class attendance by date'),
      ),
    );
  }

  Widget _periodTab(BuildContext context) {
    // Could add filters for period number/subject
    return Center(
      child: Text('Period-wise operations live with Mark dialog -> set period_number', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _analyticsTab(BuildContext context) {
    if (_dashboard == null) {
      return const Center(child: Text('No data'));
    }
    final stats = _dashboard!['stats'] ?? _dashboard!;
    return ListView(
      children: [
        _statTile('Present', stats['present_count'] ?? stats['presentcount']),
        _statTile('Absent',  stats['absent_count'] ?? stats['absentcount']),
        _statTile('Late',    stats['late_count'] ?? stats['latecount']),
        _statTile('Average Rate', stats['average_attendance_rate'] ?? stats['averageattendancerate']),
      ],
    );
  }

  Widget _statTile(String title, Object? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text('$value'),
        ],
      ),
    );
  }

  Future<void> _openMarkDialog(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => MarkAttendanceDialog(
        authorityId: widget.authorityUserId,
        service: widget.service,
      ),
    );
  }

  Future<void> _openBulkMark(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => BulkMarkDialog(
        tenantId: widget.tenantId,
        service: widget.service,
      ),
    );
  }

  Future<void> _openBulkStatus(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => BulkStatusDialog(service: widget.service),
    );
  }

  Future<void> _openBulkApprove(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => BulkApproveDialog(service: widget.service),
    );
  }

  Future<void> _openClassByDate(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => ClassByDateDialog(service: widget.service),
    );
  }
}
