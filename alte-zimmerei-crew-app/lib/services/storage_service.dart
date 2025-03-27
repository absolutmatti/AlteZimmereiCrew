import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload a single file
  Future<String> uploadFile(File file, String folderPath) async {
    try {
      String fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      String filePath = '$folderPath/$fileName';
      
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadFiles(List<File> files, String folderPath) async {
    try {
      List<String> downloadUrls = [];
      
      for (File file in files) {
        String url = await uploadFile(file, folderPath);
        downloadUrls.add(url);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload files: ${e.toString()}');
    }
  }

  // Delete a file by URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  // Delete multiple files by URL
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      for (String url in fileUrls) {
        await deleteFile(url);
      }
    } catch (e) {
      throw Exception('Failed to delete files: ${e.toString()}');
    }
  }
}

