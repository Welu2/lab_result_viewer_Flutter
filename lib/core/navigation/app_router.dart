import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lab_result_viewer/features/admin/Approval/screen/approval_screen.dart';
import 'package:lab_result_viewer/features/admin/Setting/screen/setting_screen.dart';
import 'package:lab_result_viewer/features/admin/Upload/screen/lab_screen.dart';
import 'package:lab_result_viewer/features/admin/Upload/screen/upload_screen.dart';
import 'package:lab_result_viewer/features/admin/appointment/screen/appt.dart';
import 'package:lab_result_viewer/features/admin/dashboard/screen/dashboard_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/create_profile_screen.dart';
import '../../features/home/screens/main_layout.dart';
import '../../features/home/screens/user_profile_screen.dart';
import '../../features/lab_results/screens/lab_results_screen.dart';
import '../../features/auth/screens/success_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => const MainLayout(),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen - Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/lab-results',
            builder: (context, state) => const LabResultsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-dashboard',
       builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/appointments-approval',
        builder: (context, state) => AppointmentsApprovalScreen(),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadLabReportScreen(),
      ),
      GoRoute(
        path: '/admin-upload',
        builder: (context, state) => const LabResultListScreen(),
      ),
      GoRoute(
        path: '/setting',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
        GoRoute(
        path: '/admin-appt',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
} 