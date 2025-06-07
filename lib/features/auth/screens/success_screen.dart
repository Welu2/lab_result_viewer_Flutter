import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 200),
            const SizedBox(height: 16),
            const Text('Account Created Successfully!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please complete your patient card to continue.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/create-profile');
              },
              child: const Text('Complete Patient Card'),
            ),
          ],
        ),
      ),
    );
  }
} 