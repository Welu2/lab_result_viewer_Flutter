import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lab_results_provider.dart';
import '../models/lab_result.dart';
import '../services/lab_results_service.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabResultsProvider>().fetchLabResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LabResultsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Results')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.labResults.isEmpty) {
            return const Center(child: Text('No Lab Results Found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.labResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final result = provider.labResults[index];
              return LabResultCard(result: result);
            },
          );
        },
      ),
    );
  }
}

class LabResultCard extends StatelessWidget {
  final LabResult result;
  const LabResultCard({super.key, required this.result});

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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.title ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if ((result.reportDate ?? '').isNotEmpty)
                        Text(result.reportDate!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      if ((result.reportType ?? '').isNotEmpty)
                        Text(result.reportType!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      if ((result.status ?? '').isNotEmpty)
                        Text(_statusText(result.status), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _statusColor(result.status), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _showShareDialog(context, result);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final service = context.read<LabResultsService>();
                      final url = service.getDownloadUrl(result.id);
                      _openUrl(context, url);
                    },
                    child: const Text('View Report'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final service = context.read<LabResultsService>();
                      final url = service.getDownloadUrl(result.id);
                      _openUrl(context, url);
                    },
                    child: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(BuildContext context, String url) async {
    // Use url_launcher or similar package to open the URL
    // TODO: Implement actual PDF viewing/downloading
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: $url')));
  }

  void _showShareDialog(BuildContext context, LabResult result) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  final service = context.read<LabResultsService>();
                  final downloadUrl = service.getDownloadUrl(result.id);
                  if (downloadUrl.isNotEmpty) {
                    // Copy to clipboard
                    // TODO: Implement clipboard copy
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Copy Link'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  final service = context.read<LabResultsService>();
                  final url = service.getDownloadUrl(result.id);
                  _openUrl(context, url);
                  Navigator.of(context).pop();
                },
                child: const Text('Download PDF'),
              ),
            ],
          ),
        );
      },
    );
  }
} 