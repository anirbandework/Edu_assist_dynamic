// lib/shared/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import 'navigation_header.dart';
import 'navigation_sidebar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String userRole;
  final String? tenantId;
  
  const MainLayout({
    super.key,
    required this.child,
    required this.userRole,
    this.tenantId,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    // Default sidebar state based on screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isSidebarOpen = MediaQuery.of(context).size.width > 768;
      });
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  void _handleLogout() {
    // Clear any stored data and navigate to home
    context.go(AppConstants.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Navigation
          NavigationHeader(
            onToggleSidebar: _toggleSidebar,
            userRole: widget.userRole,
            tenantId: widget.tenantId,
            onLogout: _handleLogout,
          ),
          
          // Main Content Area
          Expanded(
            child: Stack(
              children: [
                // Main Content
                Positioned.fill(
                  left: _isSidebarOpen && MediaQuery.of(context).size.width > 768 
                      ? 280 
                      : 0,
                  child: Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(16),
                    child: widget.child,
                  ),
                ),
                
                // Sidebar Overlay (Mobile)
                if (_isSidebarOpen && MediaQuery.of(context).size.width <= 768)
                  GestureDetector(
                    onTap: _closeSidebar,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                
                // Sidebar
                NavigationSidebar(
                  isOpen: _isSidebarOpen,
                  userRole: widget.userRole,
                  onClose: _closeSidebar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
