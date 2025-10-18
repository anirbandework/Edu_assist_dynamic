// lib/features/screens/school_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/tenant.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/school_session.dart';
import '../../shared/widgets/search_bar_widget.dart';
import '../../services/tenant_management_service.dart';
import '../../services/student_service.dart';
import '../../services/teacher_service.dart';
import '../../services/school_authority_service.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({super.key});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<Tenant> schools = [];
  List<Tenant> filteredSchools = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  int currentPage = 1;
  final int pageSize = 50;
  bool hasMoreData = true;
  bool includeInactive = false;

  AnimationController? animationController;
  Animation<double>? fadeAnimation;
  Animation<Offset>? slideAnimation;

  @override
  void initState() {
    super.initState();
    setupAnimations();
    searchController.addListener(filterSchools);
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSchools());
  }

  @override
  void dispose() {
    searchController.dispose();
    animationController?.dispose();
    super.dispose();
  }

  void setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController!,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController!,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    animationController!.forward();
  }

  Future<void> loadSchools([bool refresh = false]) async {
    if (!mounted) return;
    
    if (refresh) {
      currentPage = 1;
      hasMoreData = true;
      schools.clear();
    }

    setState(() {
      if (refresh) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      error = null;
    });

    try {
      final result = await TenantService.getTenants(
        page: currentPage,
        size: pageSize,
        includeInactive: includeInactive,
      );
      
      if (!mounted) return;

      final List<Tenant> newSchools = result['tenants'];
      hasMoreData = result['hasMoreData'];

      if (refresh) {
        schools = newSchools;
      } else {
        schools.addAll(newSchools);
      }
      
      filteredSchools = schools;
      currentPage++;
      
      if (searchController.text.isNotEmpty) {
        filterSchools();
      }
    } catch (e) {
      if (!mounted) return;
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> loadMoreSchools() async {
    if (!hasMoreData || isLoadingMore) return;
    await loadSchools();
  }

  void filterSchools() {
    if (!mounted) return;
    
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredSchools = schools.where((school) {
        return school.schoolName.toLowerCase().contains(query) ||
               school.address.toLowerCase().contains(query) ||
               school.principalName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void toggleIncludeInactive() {
    setState(() {
      includeInactive = !includeInactive;
    });
    loadSchools(true);
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null || fadeAnimation == null || slideAnimation == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundPrimary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: buildAppBar(),
      body: FadeTransition(
        opacity: fadeAnimation!,
        child: SlideTransition(
          position: slideAnimation!,
          child: Column(
            children: [
              buildSearchSection(),
              if (includeInactive) buildInactiveInfo(),
              Expanded(
                child: isLoading
                    ? buildLoadingState()
                    : error != null
                        ? buildErrorState()
                        : filteredSchools.isEmpty
                            ? buildEmptyState()
                            : buildSchoolsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
      toolbarHeight: 40, // Reduced from 48
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 18, // Reduced
        ),
        onPressed: () => context.go(AppConstants.homeRoute),
      ),
      title: Text(
        'Select School',
        style: AppTheme.headingSmall.copyWith(
          color: Colors.white,
          fontSize: 16, // Reduced
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            includeInactive ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
            size: 18, // Reduced
          ),
          onPressed: toggleIncludeInactive,
          tooltip: includeInactive ? 'Hide Inactive Schools' : 'Show Inactive Schools',
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 18, // Reduced
          ),
          onPressed: () => loadSchools(true),
        ),
        const SizedBox(width: 8), // Reduced
      ],
    );
  }

  Widget buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced
      decoration: const BoxDecoration(
        gradient: AppTheme.glassGreenGradient,
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200, width: 0.5),
        ),
      ),
      child: SearchBarWidget(
        controller: searchController,
        hintText: 'Search schools by name, address, or principal...',
      ),
    );
  }

  Widget buildInactiveInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced
      padding: const EdgeInsets.all(8), // Reduced
      decoration: AppTheme.getGlassDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.warning,
            size: 14, // Reduced
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing active and inactive schools',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.warning,
                fontSize: 11, // Reduced
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16), // Reduced
            decoration: BoxDecoration(
              color: AppTheme.greenPrimary.withOpacity(0.1),
              borderRadius: AppTheme.borderRadius12,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.greenPrimary,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading schools...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.neutral600,
              fontSize: 12, // Reduced
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16), // Reduced
        padding: const EdgeInsets.all(16), // Reduced
        decoration: AppTheme.getGlassDecoration(
          color: AppTheme.error.withOpacity(0.1),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12), // Reduced
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: AppTheme.borderRadius12,
              ),
              child: Icon(
                Icons.error_outline,
                size: 28, // Reduced
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Oops! Something went wrong',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.error,
                fontSize: 14, // Reduced
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.neutral600,
                fontSize: 11, // Reduced
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: AppTheme.borderRadius8,
                boxShadow: [AppTheme.cardShadow],
              ),
              child: ElevatedButton(
                onPressed: () => loadSchools(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 14), // Reduced
                    const SizedBox(width: 6),
                    Text(
                      'Try Again',
                      style: AppTheme.labelMedium.copyWith(
                        color: Colors.white,
                        fontSize: 11, // Reduced
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16), // Reduced
        padding: const EdgeInsets.all(16), // Reduced
        decoration: AppTheme.getGlassDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Reduced
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: AppTheme.borderRadius12,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 32, // Reduced
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No schools found',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.neutral600,
                fontSize: 14, // Reduced
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms or clear the search to see all schools.'
                  : includeInactive
                      ? 'No schools are currently available.'
                      : 'Try including inactive schools to see more results.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.neutral500,
                fontSize: 11, // Reduced
              ),
              textAlign: TextAlign.center,
            ),
            if (searchController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  searchController.clear();
                  filterSchools();
                },
                style: AppTheme.textButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced
                  ),
                ),
                child: Text(
                  'Clear Search',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.greenPrimary,
                    fontSize: 11, // Reduced
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSchoolsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced
      itemCount: filteredSchools.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredSchools.length) {
          return buildLoadMoreWidget();
        }
        final school = filteredSchools[index];
        return buildSchoolCard(school, index);
      },
    );
  }

  Widget buildLoadMoreWidget() {
    if (isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(12), // Reduced
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16, // Reduced
              height: 16, // Reduced
              child: const CircularProgressIndicator(
                color: AppTheme.greenPrimary,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading more schools...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.neutral600,
                fontSize: 11, // Reduced
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8), // Reduced
      child: OutlinedButton(
        onPressed: loadMoreSchools,
        style: AppTheme.outlineButtonStyle.copyWith(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10), // Reduced
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_more, size: 16), // Reduced
            const SizedBox(width: 6),
            Text(
              'Load More Schools',
              style: AppTheme.labelMedium.copyWith(
                fontSize: 11, // Reduced
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSchoolCard(Tenant school, int index) {
    final bool isInactive = !school.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 6), // Reduced
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInactive ? null : () => selectSchool(school),
          borderRadius: AppTheme.borderRadius8,
          child: Container(
            padding: const EdgeInsets.all(10), // Reduced
            decoration: AppTheme.getGlassDecoration(
              color: isInactive 
                  ? AppTheme.neutral50.withOpacity(0.5)
                  : AppTheme.surfacePrimary,
              border: Border.all(
                color: isInactive ? AppTheme.neutral300 : AppTheme.neutral200,
                width: 0.5,
              ),
            ),
            child: Opacity(
              opacity: isInactive ? 0.6 : 1.0,
              child: Row(
                children: [
                  Container(
                    width: 36, // Reduced
                    height: 36, // Reduced
                    decoration: AppTheme.getGlassDecoration(
                      color: isInactive ? AppTheme.neutral300 : AppTheme.green50,
                      borderRadius: AppTheme.borderRadius8,
                    ),
                    child: Icon(
                      Icons.school,
                      size: 20, // Reduced
                      color: isInactive ? AppTheme.neutral600 : AppTheme.greenPrimary,
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                school.schoolName,
                                style: AppTheme.labelMedium.copyWith(
                                  fontSize: 13, // Reduced
                                  fontWeight: FontWeight.bold,
                                  color: isInactive ? AppTheme.neutral600 : AppTheme.neutral900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isInactive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: AppTheme.borderRadius8,
                                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'Inactive',
                                  style: AppTheme.bodySmall.copyWith(
                                    fontSize: 8, // Reduced
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4), // Reduced
                        Text(
                          school.address,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.neutral600,
                            fontSize: 10, // Reduced
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (school.principalName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Principal: ${school.principalName}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.neutral500,
                              fontSize: 9, // Reduced
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            buildStatChip(
                              Icons.people,
                              '${school.totalStudents} students',
                              AppTheme.info,
                            ),
                            const SizedBox(width: 6),
                            buildStatChip(
                              Icons.category,
                              school.schoolType,
                              AppTheme.greenPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isInactive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced
                      decoration: BoxDecoration(
                        color: AppTheme.green50,
                        borderRadius: AppTheme.borderRadius8,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12, // Reduced
                        color: AppTheme.greenPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadius8,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color), // Reduced
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 8, // Reduced
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void selectSchool(Tenant school) {
    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: context.isMobile ? context.screenWidth * 0.9 : 320, // Reduced
          decoration: AppTheme.getGlassDecoration(
            borderRadius: AppTheme.borderRadius12,
          ),
          padding: const EdgeInsets.all(16), // Reduced
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Reduced
                decoration: const BoxDecoration(
                  gradient: AppTheme.glassGreenGradient,
                  borderRadius: AppTheme.borderRadius12,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 24, // Reduced
                      color: AppTheme.greenPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      school.schoolName,
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: 14, // Reduced
                        color: AppTheme.neutral900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (school.schoolCode != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced
                        decoration: BoxDecoration(
                          color: AppTheme.info.withOpacity(0.1),
                          borderRadius: AppTheme.borderRadius8,
                          border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                        ),
                        child: Text(
                          'School Code: ${school.schoolCode}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.info,
                            fontSize: 9, // Reduced
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Your Role',
                style: AppTheme.labelMedium.copyWith(
                  fontSize: 12, // Reduced
                  color: AppTheme.neutral800,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  buildRoleOption(
                    'Student',
                    Icons.person,
                    AppTheme.info,
                    () {
                      Navigator.pop(context);
                      showLoginDialog(school, 'student');
                    },
                  ),
                  const SizedBox(height: 8),
                  buildRoleOption(
                    'Teacher',
                    Icons.person_2,
                    AppTheme.success,
                    () {
                      Navigator.pop(context);
                      showLoginDialog(school, 'teacher');
                    },
                  ),
                  const SizedBox(height: 8),
                  buildRoleOption(
                    'School Authority',
                    Icons.admin_panel_settings,
                    AppTheme.warning,
                    () {
                      Navigator.pop(context);
                      showLoginDialog(school, 'admin');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoleOption(String role, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius8,
        child: Container(
          padding: const EdgeInsets.all(10), // Reduced
          decoration: AppTheme.getGlassDecoration(
            color: color.withOpacity(0.05),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Reduced
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadius8,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16, // Reduced
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  role,
                  style: AppTheme.labelMedium.copyWith(
                    fontSize: 12, // Reduced
                    color: AppTheme.neutral800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 12, // Reduced
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoginDialog(Tenant school, String role) {
    final TextEditingController idController = TextEditingController();
    final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

    showDialog(
      context: context,
      barrierColor: AppTheme.surfaceOverlay,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: context.isMobile ? context.screenWidth * 0.9 : 360, // Reduced
              constraints: BoxConstraints(
                maxHeight: context.screenHeight * 0.8,
              ),
              decoration: AppTheme.getGlassDecoration(
                borderRadius: AppTheme.borderRadius12,
              ),
              padding: const EdgeInsets.all(16), // Reduced
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16), // Reduced
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: AppTheme.borderRadius12,
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: Icon(
                        getRoleIcon(role),
                        size: 28, // Reduced
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Login as ${getRoleDisplayName(role)}',
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: 14, // Reduced
                        color: AppTheme.neutral900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10), // Reduced
                      decoration: AppTheme.getGlassDecoration(
                        color: AppTheme.green50,
                        border: Border.all(
                          color: AppTheme.greenPrimary.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            school.schoolName,
                            style: AppTheme.labelMedium.copyWith(
                              fontSize: 12, // Reduced
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (school.schoolCode != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'School Code: ${school.schoolCode}',
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: 10, // Reduced
                                color: AppTheme.neutral600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: idController,
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 12, // Reduced
                      ),
                      decoration: InputDecoration(
                        labelText: '${getRoleDisplayName(role)} ID',
                        hintText: getIdPlaceholder(role),
                        labelStyle: AppTheme.labelSmall.copyWith(
                          fontSize: 11, // Reduced
                        ),
                        hintStyle: AppTheme.bodySmall.copyWith(
                          fontSize: 10, // Reduced
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8), // Reduced
                          padding: const EdgeInsets.all(6), // Reduced
                          decoration: BoxDecoration(
                            color: AppTheme.greenPrimary.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadius8,
                          ),
                          child: Icon(
                            getRoleIcon(role),
                            color: AppTheme.greenPrimary,
                            size: 14, // Reduced
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutral50,
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius8,
                          borderSide: const BorderSide(color: AppTheme.neutral300, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius8,
                          borderSide: const BorderSide(color: AppTheme.greenPrimary, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, // Reduced
                          vertical: 10, // Reduced
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        if (value.trim().isNotEmpty && !isLoadingNotifier.value) {
                          performLogin(context, setState, school, role, value.trim(), isLoadingNotifier);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10), // Reduced
                      decoration: AppTheme.getGlassDecoration(
                        color: AppTheme.info.withOpacity(0.05),
                        border: Border.all(
                          color: AppTheme.info.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.info,
                            size: 14, // Reduced
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UUID Format Required',
                                  style: AppTheme.labelMedium.copyWith(
                                    fontSize: 10, // Reduced
                                    color: AppTheme.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Example: a8076f03-3873-4ff5-beea-332fa4b20003',
                                  style: AppTheme.bodySmall.copyWith(
                                    fontSize: 8, // Reduced
                                    color: AppTheme.neutral600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isLoadingNotifier,
                      builder: (context, isLoading, child) {
                        if (isLoading) {
                          return Column(
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16, // Reduced
                                    height: 16, // Reduced
                                    child: const CircularProgressIndicator(
                                      color: AppTheme.greenPrimary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verifying credentials...',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.neutral600,
                                      fontSize: 11, // Reduced
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isLoadingNotifier,
                            builder: (context, isLoading, child) {
                              return TextButton(
                                onPressed: isLoading ? null : () => Navigator.pop(context),
                                style: AppTheme.textButtonStyle.copyWith(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 10), // Reduced
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: AppTheme.labelMedium.copyWith(
                                    fontSize: 11, // Reduced
                                    color: isLoading ? AppTheme.neutral400 : AppTheme.neutral600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isLoadingNotifier,
                            builder: (context, isLoading, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: isLoading ? null : AppTheme.primaryGradient,
                                  color: isLoading ? AppTheme.neutral300 : null,
                                  borderRadius: AppTheme.borderRadius8,
                                  boxShadow: isLoading ? null : [AppTheme.cardShadow],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading 
                                      ? null 
                                      : () => performLogin(
                                          context, setState, school, role, 
                                          idController.text.trim(), isLoadingNotifier
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 16, // Reduced
                                          height: 16, // Reduced
                                          child: const CircularProgressIndicator(
                                            color: AppTheme.neutral600,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login, size: 14), // Reduced
                                            const SizedBox(width: 6),
                                            Text(
                                              'Login',
                                              style: AppTheme.labelMedium.copyWith(
                                                fontSize: 11, // Reduced
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String getIdPlaceholder(String role) {
    switch (role) {
      case 'student':
        return 'Enter your student UUID';
      case 'teacher':
        return 'Enter your teacher UUID';
      case 'admin':
        return 'Enter your authority UUID';
      default:
        return 'Enter your UUID';
    }
  }

  Future<void> performLogin(
    BuildContext dialogContext,
    StateSetter setDialogState,
    Tenant school,
    String role,
    String userId,
    ValueNotifier<bool> isLoadingNotifier,
  ) async {
    if (userId.isEmpty) {
      showErrorSnackBar('Please enter your ${getRoleDisplayName(role)} ID');
      return;
    }

    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (!uuidRegex.hasMatch(userId)) {
      showErrorSnackBar('Please enter a valid UUID format');
      return;
    }

    isLoadingNotifier.value = true;

    try {
      Map<String, dynamic> userData;
      switch (role) {
        case 'student':
          userData = await StudentService.getStudentById(userId);
          break;
        case 'teacher':
          userData = await TeacherService.getTeacherById(userId);
          break;
        case 'admin':
          userData = await AuthorityService.getAuthorityById(userId);
          break;
        default:
          throw Exception('Invalid role');
      }

      if (role != 'admin') {
        final userTenantId = userData['tenant_id']?.toString();
        if (userTenantId != null && userTenantId != school.id) {
          showErrorSnackBar('This ${getRoleDisplayName(role)} does not belong to ${school.schoolName}');
          return;
        }
      }

      // Set school data to session BEFORE navigation
      SchoolSession.setSchoolData(
        schoolName: school.schoolName,
        schoolId: school.id,
        schoolCode: school.schoolCode,
        tenantId: school.id,
      );
      
      // Debug logs
      print('DEBUG: Set school name to: ${school.schoolName}');
      print('DEBUG: SchoolSession.schoolName is now: ${SchoolSession.schoolName}');

      Navigator.pop(dialogContext);
      navigateToRole(role, school, userId, userData);
      showSuccessSnackBar('Welcome ${userData['first_name'] ?? userData['last_name'] ?? ''}!');
    } catch (e) {
      showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 14, // Reduced
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 11, // Reduced
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadius8,
        ),
        margin: const EdgeInsets.all(8), // Reduced
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 14, // Reduced
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 11, // Reduced
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadius8,
        ),
        margin: const EdgeInsets.all(8), // Reduced
      ),
    );
  }

  String getRoleDisplayName(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'teacher':
        return 'Teacher';
      case 'admin':
        return 'School Authority';
      default:
        return 'User';
    }
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.person;
      case 'teacher':
        return Icons.person_2;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void navigateToRole(String role, Tenant school, String userId, Map<String, dynamic> userData) {
    switch (role) {
      case 'student':
        context.go('${AppConstants.studentDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
      case 'teacher':
        context.go('${AppConstants.teacherDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
      case 'admin':
        context.go('${AppConstants.adminDashboardRoute}?tenantId=${school.id}&userId=$userId');
        break;
    }
  }
}
