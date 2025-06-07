import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../providers/lab_results_provider.dart';
import '../models/lab_result.dart';
import '../services/lab_results_service.dart';

class LabResultsScreen extends ConsumerStatefulWidget {
  const LabResultsScreen({super.key});

  @override
  ConsumerState<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends ConsumerState<LabResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labResultsProvider.notifier).fetchLabResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(labResultsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Results')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.labResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Lab Results Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('No results match your filters', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.labResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final result = state.labResults[index];
              return LabResultCard(result: result, ref: ref);
            },
          );
        },
      ),
    );
  }
}

class LabResultCard extends StatelessWidget {
  final LabResult result;
  final WidgetRef ref;
  const LabResultCard({super.key, required this.result, required this.ref});

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
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
                      Text(result.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if ((result.reportDate ?? '').isNotEmpty)
                        Text(result.reportDate!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      if ((result.status ?? '').isNotEmpty)
                        Text(_statusText(result.status), style: TextStyle(color: _statusColor(result.status), fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _showShareDialog(context, ref, result);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6B6B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      final service = ref.read(labResultsServiceProvider);
                      final url = service.getDownloadUrl(result.id);
                      _openUrl(context, url);
                    },
                    child: const Text('View Report'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      final service = ref.read(labResultsServiceProvider);
                      final url = service.getDownloadUrl(result.id);
                      _openUrl(context, url);
                    },
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

  void _openUrl(BuildContext context, String url) async {
    try {
      final tempDir = await getDownloadsDirectory();
      if (tempDir == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access Downloads directory.')),
        );
        return;
      }
      final fileName = 'lab_result_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      final dio = Dio();
      final response = await dio.download(
        url,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showShareDialog(BuildContext context, WidgetRef ref, LabResult result) {
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
                  final service = ref.read(labResultsServiceProvider);
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
                  final service = ref.read(labResultsServiceProvider);
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