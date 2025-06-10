import 'package:flutter/material.dart';
import '../models/lab_result.dart'; 


class LabResultCard extends StatelessWidget {
  final LabResult result;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onCopyLink;
  final VoidCallback onDownloadPdf;
  final bool isDownloading; // CORRECTED: No space in variable name

  const LabResultCard({
    Key? key,
    required this.result,
    required this.onView,
    required this.onDownload,
    required this.onCopyLink,
    required this.onDownloadPdf,
    this.isDownloading = false, // CORRECTED: Removed 'required'
  }) : super(key: key);
  
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share Result", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.all(24.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onCopyLink();
                  Navigator.of(context).pop();
                },
                child: const Text("Copy Link"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  onDownloadPdf();
                  Navigator.of(context).pop();
                },
                child: const Text("Download PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusString = result.status ?? '';
    final (statusText, statusColor) = switch (statusString.toLowerCase()) {
      "normal" || "normal results" => ("Normal Results", Colors.green[700]),
      "requires attention" => ("Requires Attention", Colors.orange[700]),
      "follow-up needed" => ("Follow-Up Needed", Colors.red[700]),
      _ => (statusString, Colors.grey),
    };

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      Text(result.title ?? 'No Title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (result.reportDate?.isNotEmpty ?? false)
                        Text(result.reportDate!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      if (result.reportType?.isNotEmpty ?? false)
                        Text(result.reportType!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      if (statusText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
                // Disable share button while this card's item is downloading
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.primary),
                  onPressed: isDownloading ? null : () => _showShareDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- CORRECTED: Added the download indicator logic to the buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isDownloading ? null : onView,
                    child: isDownloading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("View Report"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isDownloading ? null : onDownload,
                    child: const Text("Download"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- LabResultsView Widget ---
class LabResultsView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<LabResult> results;
  final Function(LabResult) onView;
  final Function(LabResult) onDownload;
  final Function(LabResult) onCopyLink;
  final Function(LabResult) onDownloadPdf;
  final int? downloadingId; // CORRECTED: Added the missing property declaration

  const LabResultsView({
    super.key,
    required this.isLoading,
    this.error,
    required this.results,
    required this.onView,
    required this.onDownload,
    required this.onCopyLink,
    required this.onDownloadPdf,
    required this.downloadingId, // Now this is correctly defined
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (results.isEmpty) {
      return const Center(child: Text('No lab results found.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        // CORRECTED: Define the variable before using it
        final bool isCurrentlyDownloading = result.id == downloadingId;

        return LabResultCard(
          result: result,
          isDownloading: isCurrentlyDownloading,
          onView: () => onView(result),
          onDownload: () => onDownload(result),
          onCopyLink: () => onCopyLink(result),
          onDownloadPdf: () => onDownloadPdf(result),
        );
      },
    );
  }
}