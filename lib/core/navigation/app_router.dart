import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/create_profile_screen.dart';
import '../../features/home/screens/main_layout.dart';
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
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Profile Screen - Coming Soon')),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Dashboard - Coming Soon')),
        ),
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