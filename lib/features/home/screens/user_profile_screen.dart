import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Remove space if not needed
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Row (Avatar, Hello, Bell)
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hello, ${profile.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Search Field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Services Title
              Text(
                'Services',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              /// Service Cards Grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ServiceCard(title: 'Ultrasound'),
                  ServiceCard(title: 'CT Scan'),
                  ServiceCard(title: 'MRI'),
                  ServiceCard(title: 'Blood Work'),
                ],
              ),

              const SizedBox(height: 20),

              /// Health Summary Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.monitor_heart, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Health Summary',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SummaryColumn(title: 'Total Tests', value: '0'),
                          SummaryColumn(title: 'Abnormal Results', value: '0'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// Bottom Navigation Bar (Optional)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile selected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Lab Results'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;

  const ServiceCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B6F71),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Book now!',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class SummaryColumn extends StatelessWidget {
  final String title;
  final String value;

  const SummaryColumn({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }
}
