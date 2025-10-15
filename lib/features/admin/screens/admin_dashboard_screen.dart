// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo[700]!, Colors.indigo[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.indigo[800],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'System Overview & Management',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Comprehensive control center for educational management system.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                'Total Schools',
                '25',
                Icons.school,
                Colors.blue,
                '+3 this month',
              ),
              _buildStatCard(
                'Total Teachers',
                '342',
                Icons.person_2,
                Colors.green,
                '+12 this month',
              ),
              _buildStatCard(
                'Total Students',
                '8,547',
                Icons.people,
                Colors.orange,
                '+45 this week',
              ),
              _buildStatCard(
                'System Health',
                '98.5%',
                Icons.health_and_safety,
                Colors.purple,
                'All systems operational',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activities & System Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Activities
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: Colors.indigo[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Activities',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'New school registered: Delhi Public School East',
                          '2 hours ago',
                          Icons.school,
                          Colors.green,
                        ),
                        _buildActivityItem(
                          '15 new teacher accounts created',
                          '5 hours ago',
                          Icons.person_add,
                          Colors.blue,
                        ),
                        _buildActivityItem(
                          'System backup completed successfully',
                          '1 day ago',
                          Icons.backup,
                          Colors.purple,
                        ),
                        _buildActivityItem(
                          'Monthly report generated for all schools',
                          '2 days ago',
                          Icons.assessment,
                          Colors.orange,
                        ),
                        _buildActivityItem(
                          'Security audit completed',
                          '3 days ago',
                          Icons.security,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // System Status & Quick Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // System Status
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStatusItem('API Services', true),
                            _buildStatusItem('Database', true),
                            _buildStatusItem('File Storage', true),
                            _buildStatusItem('Email Service', false),
                            _buildStatusItem('Backup System', true),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildQuickActionButton(
                              'Add New School',
                              Icons.add_business,
                              Colors.green,
                            ),
                            _buildQuickActionButton(
                              'Generate Reports',
                              Icons.assessment,
                              Colors.blue,
                            ),
                            _buildQuickActionButton(
                              'System Settings',
                              Icons.settings,
                              Colors.orange,
                            ),
                            _buildQuickActionButton(
                              'Backup Data',
                              Icons.cloud_upload,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Performance Metrics
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Average Response Time',
                          '245ms',
                          Icons.speed,
                          Colors.green,
                          'Excellent',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          'Daily Active Users',
                          '2,847',
                          Icons.people_alt,
                          Colors.blue,
                          '+12% from yesterday',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          'Storage Usage',
                          '78.5%',
                          Icons.storage,
                          Colors.orange,
                          '1.2TB available',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String service, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 10,
              color: isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
