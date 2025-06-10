import 'dart:io'; // Needed for File operations
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;

class FileService {
  // Copies the given text to the clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Opens the given URL. Can be a download link or a webpage.
  Future<bool> launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      
      return await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );    }
    return false;
  }

  Future<void> shareLink(String link, {String? subject}) async {
    await Share.share(link, subject: subject);
  }

  Future<String?> downloadAndSaveFile(String url, String fileName, Dio dio) async {
    if (Platform.isAndroid) {
      if (await _requestAndroidPermissions() == false) {
        print("Permission denied for file download");
        return null;
      }
    }

    Directory? downloadDir;
    if (Platform.isAndroid) {
      // Try to get the Downloads directory
      if (await _isAndroid13OrHigher()) {
        // For Android 13+, we can use the MediaStore API
        downloadDir = Directory('/storage/emulated/0/Download');
      } else {
        // For older Android versions
        downloadDir = Directory('/storage/emulated/0/Download');
      }
      
      // Create directory if it doesn't exist
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
    } else {
      downloadDir = await getApplicationDocumentsDirectory();
    }

    if (downloadDir == null) {
      print("Error: Failed to get download directory");
      return null;
    }
    
    final String savePath = path.join(downloadDir.path, fileName);
    print("Attempting to download to: $savePath");

    try {
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 404) {
        print("File not found on server. Status code: ${response.statusCode}");
        print("Response data: ${response.data}");
        return null;
      }

      if (response.statusCode != 200) {
        print("Unexpected status code: ${response.statusCode}");
        print("Response data: ${response.data}");
        return null;
      }

      final file = File(savePath);
      await file.writeAsBytes(response.data);
      
      print("File downloaded to: $savePath");
      return savePath;

    } catch (e) {
      print("Error downloading file: $e");
      if (e is DioException) {
        print("DioError details: ${e.response?.statusCode} - ${e.response?.statusMessage}");
        print("Request URL: ${e.requestOptions.uri}");
        print("Response data: ${e.response?.data}");
      }
      return null;
    }
  }

  Future<bool> _requestAndroidPermissions() async {
    if (Platform.isAndroid) {
      // First check if we already have the permissions
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Request all necessary permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      // For Android 13+ (API level 33+), we need to request media permissions
      if (await _isAndroid13OrHigher()) {
        statuses.addAll(await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request());
      }

      // Check if all permissions are granted
      bool allGranted = true;
      statuses.forEach((permission, status) {
        print("Permission $permission: $status");
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (!allGranted) {
        print("Some permissions were not granted");
        return false;
      }

      return true;
    }
    return true;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);
    print("OpenFilex result: ${result.message}");
  }
}

final fileServiceProvider = Provider<FileService>((ref) => FileService());