// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';  // This import should work now
import 'core/utils/app_router.dart';

void main() {
  runApp(const ProviderScope(
    child: EduAssistApp(),
  ));
}

class EduAssistApp extends StatelessWidget {
  const EduAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduAssist - Educational Management Platform',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
