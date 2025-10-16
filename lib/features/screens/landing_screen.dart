// lib/features/tenant_management/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/responsive.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            maxWidth: context.responsive(ResponsiveSize.maxContentWidth),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                _buildHeaderSection(context),
                
                const SizedBox(height: 40),
                
                _buildActionButtonsSection(context),
                
                const Spacer(),
                
                _buildFooterSection(context),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingSmall) + 2),
          decoration: BoxDecoration(
            color: AppTheme.surfacePrimary,
            shape: BoxShape.circle,
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Icon(
            Icons.school,
            size: context.responsive(ResponsiveSize.iconLarge) - 4,
            color: AppTheme.greenPrimary,
          ),
        ),
        SizedBox(height: context.responsive(ResponsiveSize.paddingSmall)),
        Text(
          'EduAssist',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontSize: context.responsive(ResponsiveSize.headingMedium) - 2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsive(ResponsiveSize.paddingSmall) / 2),
        Text(
          'Empowering Education Through Technology',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white70,
            fontSize: context.responsive(ResponsiveSize.bodyMedium),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    return ResponsiveRow(
      spacing: 12,
      children: [
        _buildActionButton(
          context,
          title: 'Get Started',
          subtitle: 'Select your school and continue',
          icon: Icons.rocket_launch,
          onPressed: () => context.go(AppConstants.schoolSelectionRoute),
          isPrimary: true,
        ),
        _buildActionButton(
          context,
          title: 'Manage Schools',
          subtitle: 'Add and manage educational institutions',
          icon: Icons.admin_panel_settings,
          onPressed: () => _showLoginDialog(context),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      decoration: AppTheme.getGlassDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppTheme.borderRadius10,
          child: Padding(
            padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingSmall) + 2),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingSmall) - 2),
                  decoration: BoxDecoration(
                    gradient: isPrimary ? AppTheme.primaryGradient : AppTheme.primaryGradientHover,
                    borderRadius: AppTheme.borderRadius8,
                    boxShadow: const [AppTheme.cardShadow],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: context.responsive(ResponsiveSize.iconSmall) + 2,
                  ),
                ),
                SizedBox(width: context.responsive(ResponsiveSize.paddingSmall) + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.labelMedium.copyWith(
                          fontSize: context.responsive(ResponsiveSize.bodyMedium),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.responsive(ResponsiveSize.paddingSmall) / 3),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.neutral600,
                          fontSize: context.responsive(ResponsiveSize.bodySmall),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingSmall) - 2),
                  decoration: BoxDecoration(
                    color: AppTheme.green50,
                    borderRadius: AppTheme.borderRadius6,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.greenPrimary,
                    size: context.responsive(ResponsiveSize.iconSmall) - 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Text(
      'Powering the Future of Education',
      style: AppTheme.bodySmall.copyWith(
        color: Colors.white60,
        fontSize: context.responsive(ResponsiveSize.bodySmall) - 1,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: context.isMobile ? context.screenWidth * 0.9 : 400,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: AppTheme.getGlassDecoration(
            borderRadius: AppTheme.borderRadius16,
          ),
          padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingMedium) + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(context.responsive(ResponsiveSize.paddingSmall) + 2),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.borderRadius12,
                  boxShadow: const [AppTheme.cardShadow],
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: context.responsive(ResponsiveSize.iconMedium),
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: context.responsive(ResponsiveSize.paddingSmall) + 2),
              
              Text(
                'Admin Access',
                style: AppTheme.headingSmall.copyWith(
                  fontSize: context.responsive(ResponsiveSize.headingSmall),
                  color: AppTheme.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: context.responsive(ResponsiveSize.paddingSmall) / 2),
              
              Text(
                'Access the admin panel to manage schools and educational institutions',
                style: AppTheme.bodySmall.copyWith(
                  fontSize: context.responsive(ResponsiveSize.bodySmall),
                  color: AppTheme.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: context.responsive(ResponsiveSize.paddingMedium)),
              
              context.isMobile 
                ? Column(
                    children: [
                      _buildDialogButton(context, 'Cancel', () => Navigator.pop(context), false),
                      const SizedBox(height: 8),
                      _buildDialogButton(context, 'Access Panel', () {
                        Navigator.pop(context);
                        context.go(AppConstants.tenantManagementRoute);
                      }, true),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildDialogButton(context, 'Cancel', () => Navigator.pop(context), false)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogButton(context, 'Access Panel', () {
                        Navigator.pop(context);
                        context.go(AppConstants.tenantManagementRoute);
                      }, true)),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(BuildContext context, String text, VoidCallback onPressed, bool isPrimary) {
    if (isPrimary) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.borderRadius8,
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            text,
            style: AppTheme.labelMedium.copyWith(
              color: Colors.white,
              fontSize: context.responsive(ResponsiveSize.bodySmall) + 1,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            text,
            style: AppTheme.labelMedium.copyWith(
              fontSize: context.responsive(ResponsiveSize.bodySmall) + 1,
            ),
          ),
        ),
      );
    }
  }
}
