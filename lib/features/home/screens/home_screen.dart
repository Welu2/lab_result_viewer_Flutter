import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/models/notification.dart';
import '../providers/health_summary_provider.dart';
import '../../lab_results/providers/lab_results_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/auth/session_manager.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String search = '';
  final List<String> _services = ['Ultrasound', 'CT Scan', 'MRI', 'Blood Work'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchProfile();
      final tokenFuture = SessionManager().getToken();
      tokenFuture.then((token) {
        if (token != null) {
          ref.read(notificationProvider.notifier).fetchNotifications(token);
        }
      });
    });
  }

  Future<String?> _getToken() async {
    final sessionManager = SessionManager();
    return await sessionManager.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final healthSummary = ref.watch(healthSummaryProvider);
    final notifications = ref.watch(notificationProvider);
    final unreadCount = notifications.unreadCount;
    final userName = profile.name ?? '';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final token = await _getToken();
          await Future.wait([
            ref.read(profileProvider.notifier).fetchProfile(),
            ref.read(healthSummaryProvider.notifier).fetchSummary(),
            if (token != null) ref.read(notificationProvider.notifier).fetchNotifications(token),
            ref.read(labResultsProvider.notifier).fetchLabResults(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // Top greeting bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.outline,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userName.isNotEmpty ? 'Hello, $userName' : 'Hello',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 30),
                      onPressed: () {
                        context.go('/notifications');
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search bar
            TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Services', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            // Services grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: _services.map((service) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  color: Theme.of(context).colorScheme.primary,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, size: 48, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          const Text('Book now!', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Health Summary Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monitor_heart_outlined, size: 48, color: Colors.green),
                        const SizedBox(width: 20),
                        const Text('Health Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Total Tests', style: TextStyle(fontSize: 16)),
                            Text(healthSummary.totalTests.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Abnormal Results', style: TextStyle(fontSize: 16)),
                            Text(healthSummary.abnormalResults.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // You can add more sections below as needed (e.g., recent lab results, notifications)
          ],
        ),
      ),
    );
  }
} 