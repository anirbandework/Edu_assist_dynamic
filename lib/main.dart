// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/services/ai_assistant_manager.dart';
import 'shared/widgets/ai_assistant_widget.dart';

void main() {
  runApp(const ProviderScope(
    child: EduAssistApp(),
  ));
}

class EduAssistApp extends ConsumerStatefulWidget {
  const EduAssistApp({super.key});

  @override
  ConsumerState<EduAssistApp> createState() => _EduAssistAppState();
}

class _EduAssistAppState extends ConsumerState<EduAssistApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the AI assistant after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AIAssistantManager.initialize(ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduAssist - Educational Management Platform',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // Show your existing AI Assistant widget
              Consumer(
                builder: (context, ref, _) {
                  final assistantState = ref.watch(aiAssistantProvider);
                  return assistantState.isVisible 
                      ? const AIAssistantWidget()
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
