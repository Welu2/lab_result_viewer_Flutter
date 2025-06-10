import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab_result_viewer/main.dart' as app;

// Import everything you need to create your services, just like in main.dart
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:lab_result_viewer/features/auth/providers/auth_provider.dart';
import 'package:lab_result_viewer/features/auth/services/auth_service.dart';
import 'package:lab_result_viewer/features/home/providers/profile_provider.dart';
import 'package:lab_result_viewer/features/home/services/profile_service.dart';
import 'package:lab_result_viewer/features/notifications/providers/notification_provider.dart';
import 'package:lab_result_viewer/features/notifications/services/notification_service.dart' as notif_service;
import 'package:lab_result_viewer/features/home/providers/health_summary_provider.dart';
import 'package:lab_result_viewer/features/lab_results/providers/lab_results_provider.dart';
import 'package:lab_result_viewer/features/lab_results/services/lab_results_service.dart';
import 'package:lab_result_viewer/features/admin/dashboard/provider/dashboard_provider.dart';
import "package:lab_result_viewer/features/admin/dashboard/service/dashboard_service.dart";
import 'package:lab_result_viewer/features/admin/Approval/provider/approval_provider.dart';
import "package:lab_result_viewer/features/admin/Approval/services/approval_service.dart";
import 'package:lab_result_viewer/features/admin/appointment/provider/appt_provider.dart';
import 'package:lab_result_viewer/features/admin/appointment/service/appt_service.dart';
import "package:lab_result_viewer/features/admin/Upload/provider/upload_provider.dart";
import 'package:lab_result_viewer/features/admin/Upload/service/upload_service.dart';
import 'package:lab_result_viewer/features/admin/Upload/provider/lab_result_providers.dart';
import 'package:lab_result_viewer/features/admin/Upload/service/lab_result_service.dart';


import 'package:lab_result_viewer/widgets/custom_text_field.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Test', () {
    testWidgets('Full login flow: from Welcome Screen to Home', (WidgetTester tester) async {
      
      // --- START: Replicate the setup from main.dart ---
      final apiClient = ApiClient();
      final sessionManager = SessionManager();

      // Initialize all services exactly as in main.dart
      final authService = AuthService(apiClient, sessionManager);
      final profileService = ProfileService(sessionManager, apiClient);
      final notificationService = notif_service.NotificationService(apiClient.dio);
      final healthSummaryService = HealthSummaryService(apiClient);
      final labResultsService = LabResultsService(apiClient);
      final dashboardService = DashboardService(apiClient);
      final appointmentService = AppointmentsService(apiClient);
      final appts = AppointmentService(apiClient);
      final report = LabReportService(apiClient);
      final lab = LabService(apiClient);
      // --- END: Replicated setup ---

      // Now, use this setup to run the app in the test environment
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provide all the overrides exactly as in main.dart
            authServiceProvider.overrideWithValue(authService),
            profileServiceProvider.overrideWithValue(profileService),
            notificationServiceProvider.overrideWithValue(notificationService),
            healthSummaryServiceProvider.overrideWithValue(healthSummaryService),
            labResultsServiceProvider.overrideWithValue(labResultsService),
            dashboardServiceProvider.overrideWithValue(dashboardService),
            appointmentsServiceProvider.overrideWithValue(appointmentService),
            appointmentServiceProvider.overrideWithValue(appts),
            labReportServiceProvider.overrideWithValue(report),
            labServiceProvider.overrideWithValue(lab),
          ],
          child: const app.MyApp(), // Use the MyApp from your app's code
        ),
      );
      
      // The rest of your test remains the same
      await tester.pumpAndSettle();

      expect(find.text('Welcome to PULSE'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsAtLeastNWidgets(1));
      expect(find.text('Welcome Back!'), findsOneWidget);

      final emailFieldFinder = find.widgetWithText(CustomTextField, 'Enter your email');
      final passwordFieldFinder = find.widgetWithText(CustomTextField, 'Create Password');

      await tester.enterText(emailFieldFinder, 'serkes@gmail.com');
      await tester.enterText(passwordFieldFinder, 'H.123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('CT Scan'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsNothing);

      await tester.tap(find.text('Appt.'));
      await tester.pumpAndSettle();

      expect(find.text('Book New Appointment'), findsOneWidget);
      await tester.tap(find.text('Book New Appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Test Type'), findsWidgets);
      expect(find.text('Preferred Date'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Ultrasound').last); 
      await tester.pumpAndSettle();

      await tester.tap(find.text('10:30 AM'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Successfully Scheduled'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Successfully Scheduled'), findsNothing);
    });

    testWidgets('User can view and download lab result', (WidgetTester tester) async {
      // --- Setup (same as main.dart) ---
      final apiClient = ApiClient();
      final sessionManager = SessionManager();
      final authService = AuthService(apiClient, sessionManager);
      final profileService = ProfileService(sessionManager, apiClient);
      final notificationService = notif_service.NotificationService(apiClient.dio);
      final healthSummaryService = HealthSummaryService(apiClient);
      final labResultsService = LabResultsService(apiClient);
      final dashboardService = DashboardService(apiClient);
      final appointmentService = AppointmentsService(apiClient);
      final appts = AppointmentService(apiClient);
      final report = LabReportService(apiClient);
      final lab = LabService(apiClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            profileServiceProvider.overrideWithValue(profileService),
            notificationServiceProvider.overrideWithValue(notificationService),
            healthSummaryServiceProvider.overrideWithValue(healthSummaryService),
            labResultsServiceProvider.overrideWithValue(labResultsService),
            dashboardServiceProvider.overrideWithValue(dashboardService),
            appointmentsServiceProvider.overrideWithValue(appointmentService),
            appointmentServiceProvider.overrideWithValue(appts),
            labReportServiceProvider.overrideWithValue(report),
            labServiceProvider.overrideWithValue(lab),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Login flow (reuse from previous test)
      await tester.tap(find.widgetWithText(OutlinedButton, 'Log In'));
      await tester.pumpAndSettle();
      final emailFieldFinder = find.widgetWithText(CustomTextField, 'Enter your email');
      final passwordFieldFinder = find.widgetWithText(CustomTextField, 'Create Password');
      await tester.enterText(emailFieldFinder, 'serkes@gmail.com');
      await tester.enterText(passwordFieldFinder, 'H.123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Lab Results tab
      await tester.tap(find.text('Lab Results'));
      await tester.pumpAndSettle();
      expect(find.text('Lab Results'), findsWidgets);
      // Wait for results to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the first Download button and tap it
      final downloadButton = find.widgetWithText(OutlinedButton, 'Download').first;
      expect(downloadButton, findsOneWidget);
      await tester.tap(downloadButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Optionally, check for a loading indicator or a SnackBar (if any)
      // expect(find.byType(CircularProgressIndicator), findsWidgets);
      // Or check for file open/download logic if possible
    });
  });
}