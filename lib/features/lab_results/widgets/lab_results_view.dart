import 'package:flutter/material.dart';
import '../models/lab_result.dart';

/// A pure, stateless widget that renders:
///  • A loading spinner if [isLoading]
///  • An error message if [error] is non-null
///  • An “empty” placeholder if [results] is empty
///  • A ListView of [LabResultCard] if [results] is non-empty
class LabResultsView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<LabResult> results;

  /// Called when the user taps the share icon for a result.
  final void Function(LabResult) onShare;

  /// Called when the user taps the “View Report” or “Download” button.
  final void Function(LabResult) onOpen;

  const LabResultsView({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.results,
    required this.onShare,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No Lab Results Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('No results match your filters',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = results[i];
        return LabResultCard(
          result: r,
          onShare: () => onShare(r),
          onOpen: () => onOpen(r),
        );
      },
    );
  }
}

/// A slimmed‐down version of your card that only needs two callbacks.
class LabResultCard extends StatelessWidget {
  final LabResult result;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  const LabResultCard({
    Key? key,
    required this.result,
    required this.onShare,
    required this.onOpen,
  }) : super(key: key);

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'normal':
      case 'normal results':
        return const Color(0xFF3CB371);
      case 'requires attention':
        return const Color(0xFFFFA500);
      case 'follow-up needed':
        return const Color(0xFFDB3B3B);
      default:
        return Colors.grey;
    }
  }

  String _statusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'normal':
      case 'normal results':
        return 'Normal Results';
      case 'requires attention':
        return 'Requires Attention';
      case 'follow-up needed':
        return 'Follow-Up Needed';
      default:
        return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title, date, status
            Text(result.title ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            if ((result.reportDate ?? '').isNotEmpty)
              Text(result.reportDate!,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
            if ((result.status ?? '').isNotEmpty)
              Text(_statusText(result.status),
                  style: TextStyle(
                      color: _statusColor(result.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            // Share button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: onShare,
              ),
            ),
            const SizedBox(height: 8),
            // View/Download buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpen,
                    child: const Text('View Report'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.download_outlined, size: 18),
                        SizedBox(width: 4),
                        Text('Download'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
