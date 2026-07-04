import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload 1 asset ke Firebase Storage, return download URL
  Future<String> uploadAsset(String assetPath, String storagePath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final ref = _storage.ref().child(storagePath);
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: _mimeType(assetPath)),
    );
    return await task.ref.getDownloadURL();
  }

  // Ambil URL file yang sudah ada di Storage
  Future<String?> getUrl(String storagePath) async {
    try {
      return await _storage.ref().child(storagePath).getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // Upload semua assets sekaligus, return map assetPath → downloadUrl
  Future<Map<String, String>> uploadAllAssets(
    List<String> assetPaths, {
    void Function(int done, int total)? onProgress,
  }) async {
    final result = <String, String>{};
    for (int i = 0; i < assetPaths.length; i++) {
      final path = assetPaths[i];
      try {
        final fileName = path.split('/').last;
        final url = await uploadAsset(path, 'assets/$fileName');
        result[path] = url;
      } catch (_) {}
      onProgress?.call(i + 1, assetPaths.length);
    }
    return result;
  }

  String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      case 'gif':  return 'image/gif';
      case 'mp4':  return 'video/mp4';
      default:     return 'application/octet-stream';
    }
  }
}
