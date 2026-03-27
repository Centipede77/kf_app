import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class PhotoManager {
  Future<String> get _photoDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/contact_photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir.path;
  }

  Future<String?> savePhoto(File sourceFile) async {
    try {
      final dir = await _photoDirectory;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(999999);
      final extension = _safeExtension(sourceFile.path);
      final fileName = 'photo_${timestamp}_$random$extension';
      final targetPath = '$dir/$fileName';

      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (_) {
      return null;
    }
  }

  Future<File?> getPhoto(String? photoPath) async {
    if (photoPath == null || photoPath.trim().isEmpty) return null;

    final file = File(photoPath);
    if (await file.exists()) {
      return file;
    }

    return null;
  }

  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null || photoPath.trim().isEmpty) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore
    }
  }

  String _safeExtension(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.jpeg')) return '.jpeg';
    if (lower.endsWith('.jpg')) return '.jpg';
    if (lower.endsWith('.webp')) return '.webp';

    return '.jpg';
  }
}