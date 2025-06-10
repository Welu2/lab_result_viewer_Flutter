import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab_result_viewer/main.dart' as app;
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

Widget createTestApp() {
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

  return ProviderScope(
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
  );
}

Future<void> logoutViaUI(WidgetTester tester) async {
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Log out'));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  final confirmLogoutButton = find.text('Log Out').last;
  expect(confirmLogoutButton, findsOneWidget, reason: "Logout confirmation button should be visible");
  await tester.tap(confirmLogoutButton);
  
  await tester.pumpAndSettle(const Duration(seconds: 2));

  await tester.pump(const Duration(seconds: 1));
  
  expect(find.widgetWithText(CustomTextField, 'Enter your email'), findsOneWidget,
    reason: 'After logout, should show login screen with email field');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Test', () {
    testWidgets('User can log in, book an appointment, and log out', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.widgetWithText(OutlinedButton, 'Log In'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(CustomTextField, 'Enter your email'), 'serkess@gmail.com');
      await tester.enterText(find.widgetWithText(CustomTextField, 'Create Password'), 'H.123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('CT Scan'), findsOneWidget);

      // Book Appointment
      await tester.tap(find.text('Appt.'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Book New Appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ultrasound').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('10:30 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Successfully Scheduled'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Logout via UI to clean up for the next test
      await logoutViaUI(tester);
    });

    testWidgets('User can view lab results', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.widgetWithText(CustomTextField, 'Enter your email'), 'serkess@gmail.com');
      await tester.enterText(find.widgetWithText(CustomTextField, 'Create Password'), 'H.123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('CT Scan'), findsOneWidget);

      await tester.tap(find.text('Lab Results'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Card), findsWidgets);
      
      await logoutViaUI(tester);
    });

    testWidgets('Admin can log in and approve an appointment', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.widgetWithText(CustomTextField, 'Enter your email'), 'Admin@pulse.org');
      await tester.enterText(find.widgetWithText(CustomTextField, 'Create Password'), 'H.123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      
      final notificationIcon = find.byIcon(Icons.notifications_outlined);
      expect(notificationIcon, findsOneWidget, reason: 'Notification icon should be visible');
      await tester.tap(notificationIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Approvals'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(Card), findsWidgets);

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget, reason: 'Back button should be visible');
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}