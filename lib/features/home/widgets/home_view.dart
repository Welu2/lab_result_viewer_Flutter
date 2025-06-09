import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  final String userName;
  final int unreadNotifications;
  final int totalTests;
  final int abnormalResults;
  final List<String> services;

  /// Called when the notification icon is tapped.
  final VoidCallback onNotificationsTap;

  /// Called when the user pulls to refresh.
  final Future<void> Function() onRefresh;

  /// Called when the search text changes.
  final ValueChanged<String> onSearchChanged;

  /// Called when a service card is tapped.
  final ValueChanged<String> onServiceTap;

  const HomeView({
    Key? key,
    required this.userName,
    required this.unreadNotifications,
    required this.totalTests,
    required this.abnormalResults,
    required this.services,
    required this.onNotificationsTap,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onServiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
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
                      onPressed: onNotificationsTap,
                    ),
                    if (unreadNotifications > 0)
                      const Positioned(
                        right: 8,
                        top: 8,
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
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
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
              children: services.map((service) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  color: Theme.of(context).colorScheme.primary,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onServiceTap(service),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 48, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(service,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white)),
                          const Text('Book now!',
                              style: TextStyle(color: Colors.white)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.monitor_heart_outlined,
                            size: 48, color: Colors.green),
                        SizedBox(width: 20),
                        Text('Health Summary',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Total Tests',
                                style: TextStyle(fontSize: 16)),
                            Text(totalTests.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Abnormal Results',
                                style: TextStyle(fontSize: 16)),
                            Text(abnormalResults.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ],
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
}
