import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadFile(BuildContext context, String name, Uint8List bytes,
    {String? type = 'file'}) async {
  // var status = await Permission.manageExternalStorage.status;
  // print(Permission.manageExternalStorage.status);
  // print(status);
  // status = await Permission.manageExternalStorage.request();
  var status = await Permission.manageExternalStorage.isDenied;
  if (status) {
    Permission.manageExternalStorage.request();
  }
  try {
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) throw Exception("Directory not found");

    // Create directory if it doesn't exist
    await downloadsDir.create(recursive: true);
    final file;
    if (type == 'file') {
      file = File('${downloadsDir.path}/$name');
    } else {
      file = File('${downloadsDir.path}/$name.zip');
    }

    // Write bytes to the file
    await file.writeAsBytes(bytes);

    // Optionally show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(type == 'file'
              ? 'File downloaded: $name'
              : 'Folder downloaded: $name')),
    );

    // Open the file
    await OpenFile.open(file.path);
    // }
  } catch (e) {
    print("Download error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error downloading file')),
    );
  }
}
