import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/lab_result_providers.dart';
import '../../dashboard/provider/dashboard_provider.dart';
import '../provider/notify.dart';

class UploadLabReportScreen extends ConsumerStatefulWidget {
  const UploadLabReportScreen({super.key});

  @override
  ConsumerState<UploadLabReportScreen> createState() =>
      _UploadLabReportScreenState();
}

class _UploadLabReportScreenState extends ConsumerState<UploadLabReportScreen> {
  PlatformFile? selectedFile;
  String patientId = '';
  String testType = '';
  final List<String> testTypes = ["Blood Test", "Urine Test", "X-Ray", "Other"];

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // IMPORTANT: Load file bytes here
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
      debugPrint('File picked: ${selectedFile?.name}');
    } else {
      setState(() {
        selectedFile = null;
      });
      debugPrint('No file picked');
    }
  }


  void showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadLabReportProvider);

    ref.listen(uploadLabReportProvider, (previous, next) {
      next.when(
        data: (message) {
          if (message.isNotEmpty) {
            ref.invalidate(labResultsProvider);
            ref.invalidate(dashboardProvider);
            showSnackBar(message);
            setState(() {
              selectedFile = null;
              patientId = '';
              testType = '';
            });
          }
        },
        loading: () {},
        error: (e, _) {
          showSnackBar(e.toString(), isError: true);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Lab Report"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin-upload'); // Navigates to /upload using GoRouter
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Center(
                    child: selectedFile == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                "Tap to select a file",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.insert_drive_file,
                                  size: 40, color: Colors.blueGrey),
                              const SizedBox(height: 8),
                              Text(
                                selectedFile?.name ?? 'No file selected',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => patientId = value),
                decoration: const InputDecoration(labelText: "Patient ID"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: testType.isEmpty ? null : testType,
                items: testTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => testType = value ?? ''),
                decoration: const InputDecoration(labelText: "Test Type"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: selectedFile != null &&
                        patientId.isNotEmpty &&
                        testType.isNotEmpty &&
                        !uploadState.isLoading
                    ? () {
                        final file = selectedFile;
                        if (file == null) {
                          // Defensive check: show error and do nothing
                          showSnackBar('No file selected for upload.',
                              isError: true);
                          return;
                        }
                        debugPrint('Uploading file: ${file.name}');
                        ref.read(uploadLabReportProvider.notifier).upload(
                              platformFile: file,
                              patientId: patientId,
                              testType: testType,
                            );
                      }
                    : null,
                child: uploadState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Upload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
