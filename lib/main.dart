import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api/api_client.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/session_manager.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/home/providers/profile_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/home/providers/health_summary_provider.dart';
import 'features/lab_results/providers/lab_results_provider.dart';
import 'features/lab_results/services/lab_results_service.dart';
import 'features/notifications/services/notification_service.dart' as notif_service;
import 'package:dio/dio.dart';

void main() {
  final apiClient = ApiClient();
  final sessionManager = SessionManager();

  // Initialize services
  final authService = AuthService(apiClient, sessionManager);
  final profileService = ProfileService(sessionManager, apiClient);
  final notificationService = notif_service.NotificationService(apiClient.dio);
  final healthSummaryService = HealthSummaryService(apiClient);
  final labResultsService = LabResultsService(apiClient);

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        profileServiceProvider.overrideWithValue(profileService),
        notificationServiceProvider.overrideWithValue(notificationService),
        healthSummaryServiceProvider.overrideWithValue(healthSummaryService),
        labResultsServiceProvider.overrideWithValue(labResultsService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Lab Result Viewer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
