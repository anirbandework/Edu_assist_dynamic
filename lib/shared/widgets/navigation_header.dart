// lib/shared/widgets/navigation_header.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class NavigationHeader extends StatefulWidget {
  final VoidCallback onToggleSidebar;
  final String userRole;
  final String? tenantId;
  final VoidCallback onLogout;

  const NavigationHeader({
    super.key,
    required this.onToggleSidebar,
    required this.userRole,
    this.tenantId,
    required this.onLogout,
  });

  @override
  State<NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<NavigationHeader> {

  String _getPortalTitle() {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return 'EduAssist Admin Portal';
      case 'teacher':
        return 'EduAssist Teacher Portal';
      case 'student':
        return 'EduAssist Student Portal';
      default:
        return 'EduAssist Portal';
    }
  }

  String _getUserInitials() {
    // You can get this from user data stored in app state
    return 'JD'; // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.lightGreen, AppTheme.primaryGreen], // Using your green theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Hamburger Menu
            IconButton(
              onPressed: widget.onToggleSidebar,
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Logo and Title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'EA',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getPortalTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Educational Management',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const Spacer(),
            
            // School Info (Desktop)
            if (MediaQuery.of(context).size.width > 768)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delhi Public School',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(width: 16),
            
            // User Profile Dropdown
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  widget.onLogout();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Text(
                        _getUserInitials(),
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (MediaQuery.of(context).size.width > 600) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.userRole.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      Icons.person, 
                      color: AppTheme.primaryGreen,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: AppTheme.primaryGreen,
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                    dense: true,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red[600]),
                    title: Text(
                      'Logout', 
                      style: TextStyle(color: Colors.red[600]),
                    ),
                    dense: true,
                  ),
                ),
              ],
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
