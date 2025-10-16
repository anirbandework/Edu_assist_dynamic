// lib/shared/widgets/navigation_header.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/school_session.dart';

class NavigationHeader extends StatefulWidget {
  final VoidCallback onToggleSidebar;
  final String userRole;
  final String? tenantId;
  final VoidCallback onLogout;
  final String? userName;
  final String? schoolName;
  final int notificationCount;

  const NavigationHeader({
    super.key,
    required this.onToggleSidebar,
    required this.userRole,
    this.tenantId,
    required this.onLogout,
    this.userName,
    this.schoolName,
    this.notificationCount = 0,
  });

  @override
  State<NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<NavigationHeader> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getPortalTitle() {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
      case 'school_authority':
        return 'Admin Portal';
      case 'teacher':
        return 'Teacher Portal';
      case 'student':
        return 'Student Portal';
      case 'global_admin':
        return 'Global Admin';
      case 'tenant_manager':
        return 'Manager';
      default:
        return 'EduAssist';
    }
  }

  String _getUserInitials() {
    final name = widget.userName ?? 'John Doe';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'JD';
  }

  String _getRoleDisplayName() {
    switch (widget.userRole.toLowerCase()) {
      case 'global_admin': return 'GLOBAL';
      case 'tenant_manager': return 'MANAGER';
      case 'admin':
      case 'school_authority': return 'ADMIN';
      case 'teacher': return 'TEACHER';
      case 'student': return 'STUDENT';
      default: return widget.userRole.toUpperCase();
    }
  }

  bool _isGlobalUser() {
    return widget.userRole.toLowerCase() == 'global_admin' || 
           widget.userRole.toLowerCase() == 'tenant_manager';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 48,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            boxShadow: [AppTheme.microShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Hamburger Menu
                _buildMenuButton(context),
                
                const SizedBox(width: 6),
                
                // Logo and Title
                _buildLogoSection(context),
                
                const Spacer(),
                
                // Notifications (Mobile)
                if (context.isMobile && widget.notificationCount > 0)
                  _buildNotificationButton(context),
                
                // School Info - Always show
                _buildSchoolInfo(context),
                
                const SizedBox(width: 6),
                
                // COMMENTED OUT: User Profile Avatar Section
                // _buildUserProfileAvatar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return InkWell(
      onTap: widget.onToggleSidebar,
      borderRadius: AppTheme.borderRadius6,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.getMicroDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          Icons.menu,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Row(
      children: [
        // Logo Container
        Container(
          width: 24,
          height: 24,
          decoration: AppTheme.getMicroDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadius6,
          ),
          child: Center(
            child: Text(
              'EA',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.greenPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Title (Hidden on very small screens)
        if (context.screenWidth > 320) ...[
          const SizedBox(width: 6),
          Text(
            _getPortalTitle(),
            style: AppTheme.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to notifications
      },
      borderRadius: AppTheme.borderRadius6,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.getMicroDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications,
              color: Colors.white,
              size: 16,
            ),
            if (widget.notificationCount > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: AppTheme.borderRadius8,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    widget.notificationCount > 9 ? '9+' : widget.notificationCount.toString(),
                    style: TextStyle(
                      fontSize: 6,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.bauhausFontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfo(BuildContext context) {
    // Get school name from session with debug logging
    final sessionSchoolName = SchoolSession.schoolName;
    final widgetSchoolName = widget.schoolName;
    
    // Debug logging
    print('DEBUG: SchoolSession.schoolName = $sessionSchoolName');
    print('DEBUG: widget.schoolName = $widgetSchoolName');
    print('DEBUG: SchoolSession.hasSchoolData = ${SchoolSession.hasSchoolData}');
    
    final schoolName = sessionSchoolName ?? widgetSchoolName ?? 'No School Selected';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: AppTheme.getMicroDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppTheme.borderRadius6,
            ),
            child: Icon(
              _isGlobalUser() ? Icons.public : Icons.school,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.screenWidth * 0.25,
            ),
            child: Text(
              _isGlobalUser() ? 'Global System' : _shortenSchoolName(schoolName),
              style: AppTheme.bodyMicro.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _shortenSchoolName(String name) {
    if (name.length <= 20) return name;
    return '${name.substring(0, 17)}...';
  }

  // COMMENTED OUT: User Profile Avatar Section
  /*
  Widget _buildUserProfileAvatar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: AppTheme.getMicroDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Avatar
          Stack(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.borderRadius6,
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.greenPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.bauhausFontFamily,
                    ),
                  ),
                ),
              ),
              if (widget.notificationCount > 0 && !context.isMobile)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: AppTheme.borderRadius8,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
          
          // User Info (Tablet/Desktop) - Show role only
          if (context.isTablet || context.isDesktop) ...[
            const SizedBox(width: 6),
            Text(
              _getRoleDisplayName(),
              style: TextStyle(
                fontSize: 7,
                color: Colors.white70,
                fontFamily: AppTheme.bauhausFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
  */

  String _shortenUserName(String name) {
    if (name.length <= 10) return name;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return '${name.substring(0, 8)}...';
  }
}

// Enhanced version with breadcrumbs
class AdvancedNavigationHeader extends StatelessWidget {
  final VoidCallback onToggleSidebar;
  final String userRole;
  final String? tenantId;
  final VoidCallback onLogout;
  final String? userName;
  final String? schoolName;
  final int notificationCount;
  final List<Widget>? additionalActions;
  final bool showBreadcrumbs;
  final List<String>? breadcrumbs;

  const AdvancedNavigationHeader({
    super.key,
    required this.onToggleSidebar,
    required this.userRole,
    this.tenantId,
    required this.onLogout,
    this.userName,
    this.schoolName,
    this.notificationCount = 0,
    this.additionalActions,
    this.showBreadcrumbs = false,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          onToggleSidebar: onToggleSidebar,
          userRole: userRole,
          tenantId: tenantId,
          onLogout: onLogout,
          userName: userName,
          schoolName: schoolName,
          notificationCount: notificationCount,
        ),
        
        // Breadcrumbs Section
        if (showBreadcrumbs && breadcrumbs != null && breadcrumbs!.isNotEmpty)
          Container(
            height: 32,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.green50,
              border: Border(
                bottom: BorderSide(color: AppTheme.neutral200.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  size: 12,
                  color: AppTheme.greenPrimary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: breadcrumbs!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final breadcrumb = entry.value;
                        final isLast = index == breadcrumbs!.length - 1;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              breadcrumb,
                              style: AppTheme.bodyMicro.copyWith(
                                color: isLast ? AppTheme.greenPrimary : AppTheme.neutral600,
                                fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (!isLast) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right,
                                size: 10,
                                color: AppTheme.neutral400,
                              ),
                              const SizedBox(width: 3),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (additionalActions != null) ...additionalActions!,
              ],
            ),
          ),
      ],
    );
  }
}
