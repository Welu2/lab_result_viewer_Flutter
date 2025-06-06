import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final sessionManager = SessionManager();
    final authService = AuthService(apiClient, sessionManager);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(sessionManager, apiClient),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            apiClient: apiClient,
            sessionManager: sessionManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthSummaryProvider(apiClient),
        ),
        Provider(
          create: (_) => LabResultsService(apiClient),
        ),
        ChangeNotifierProvider(
          create: (context) => LabResultsProvider(context.read<LabResultsService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lab Result Viewer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
