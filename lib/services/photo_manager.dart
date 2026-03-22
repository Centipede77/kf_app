import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoManager {
  Future<String> get _photoDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir.path;
  }

  Future<String?> savePhoto(File source) async {
    try {
      final dir = await _photoDirectory;
      final name =
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = '$dir/$name';
      await source.copy(path);

      return path;
    } catch (e) {
      return null;
    }
  }

  Future<void> deletePhoto(String? path) async {
    if (path == null) return;

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}