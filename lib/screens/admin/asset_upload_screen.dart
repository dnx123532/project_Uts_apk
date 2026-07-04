import 'package:flutter/material.dart';
import 'package:project_uts_apk/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Semua asset gambar yang akan diupload ke Firebase Storage
const _assetImages = [
  // Cinema
  'assets/images/Grand_Indonesia.jpg',
  'assets/images/Senayan_city.jpg',
  'assets/images/Kelapa_Gading.jpg',
  'assets/images/Ciwalk_Bandung.jpg',
  'assets/images/Paris_Van_Java.jpeg',
  'assets/images/TransStudio Mall.jpg',
  'assets/images/Trans_Studio_Mall.jpeg',
  'assets/images/Pentacity.jpg',
  'assets/images/E-Walk.jpg',
  'assets/images/Mega Mall.jpg',
  'assets/images/Grand Batam Mall.png',
  'assets/images/Batam Mall.jpg',
  'assets/images/Summarecon Mall.jpg',
  'assets/images/Mega Bekasi.jpg',
  'assets/images/Bekasi.jpg',
  'assets/images/Botani.jpg',
  'assets/images/Cibinong City.jpg',
  'assets/images/panukkanga.jpg',
  'assets/images/Palembang-Icon-Mall-PhotoRoom.jpg',
  'assets/images/Palembang-Square-PhotoRoom.jpg',
  'assets/images/Medan Fair.jpg',
  'assets/images/Lippo.jpeg',
  'assets/images/SunPlaza.jpeg',
  'assets/images/Hermes Place.jpg',
  'assets/images/Bogor.png',
  // Food & Beverage
  'assets/images/Combo_1.png',
  'assets/images/Combo1_Popcorn_ Minuman.png',
  'assets/images/Combo_2_Popcorn_Besar_2_Minuman.png',
  'assets/images/Combo 3_Family_Pack.png',
  'assets/images/online_exclusive combo _sweeet.png',
  'assets/images/online_exclusive_combo_2.png',
  'assets/images/combo_savory.png',
  'assets/images/Popcorn_Small.png',
  'assets/images/Popcorn_Medium.png',
  'assets/images/Popcorn_Large.png',
  'assets/images/Nachos_+_Cheese.png',
  'assets/images/HotDog.png',
  'assets/images/Coca-Cola_Regular.png',
  'assets/images/Coca-Cola_Large.png',
  'assets/images/Air_Mineral.png',
  'assets/images/Juice_Jeruk.png',
  // Film
  'assets/images/avengerendgame.webp',
  'assets/images/avengersinfinitywar.jpeg',
  'assets/images/chainsawman.jpeg',
  'assets/images/jujutsukaisen.jpeg',
  'assets/images/lookback.jpeg',
  'assets/images/nowyouseeme.jpeg',
  'assets/images/oneforall.jpeg',
  'assets/images/panukkanga.jpg',
  'assets/images/theconjuring.webp',
  'assets/images/thedarkknight.jpeg',
  'assets/images/toystory4.jpeg',
  // Sponsor
  'assets/images/sponsor1.png',
  'assets/images/sponsor2.png',
];

class AssetUploadScreen extends StatefulWidget {
  const AssetUploadScreen({super.key});

  @override
  State<AssetUploadScreen> createState() => _AssetUploadScreenState();
}

class _AssetUploadScreenState extends State<AssetUploadScreen> {
  final _storage = StorageService();
  bool _isUploading = false;
  int _done = 0;
  int _total = 0;
  String _currentFile = '';
  final List<String> _log = [];
  Map<String, String> _uploadedUrls = {};

  Future<void> _startUpload() async {
    setState(() {
      _isUploading = true;
      _done = 0;
      _total = _assetImages.length;
      _log.clear();
      _uploadedUrls = {};
    });

    final urls = await _storage.uploadAllAssets(
      _assetImages,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _done = done;
          _currentFile = _assetImages[done - 1].split('/').last;
          _log.add('✅ $_currentFile');
        });
      },
    );

    // Simpan semua URL ke Firestore collection 'asset_urls'
    // supaya app bisa fetch tanpa hardcode
    final batch = FirebaseFirestore.instance.batch();
    urls.forEach((assetPath, url) {
      final fileName = assetPath.split('/').last;
      final ref = FirebaseFirestore.instance
          .collection('asset_urls')
          .doc(fileName);
      batch.set(ref, {'url': url, 'assetPath': assetPath});
    });
    await batch.commit();

    setState(() {
      _isUploading = false;
      _uploadedUrls = urls;
      _log.add('');
      _log.add('🎉 Selesai! ${urls.length}/${_assetImages.length} file berhasil diupload.');
      _log.add('URL tersimpan di Firestore → asset_urls');
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? 0.0 : _done / _total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Upload Assets ke Firebase Storage'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jalankan SEKALI SAJA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_assetImages.length} file akan diupload ke Firebase Storage.\n'
                    'URL otomatis tersimpan ke Firestore (asset_urls).\n'
                    'Setelah selesai, app bisa load gambar dari server.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress
            if (_isUploading || _done > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isUploading ? 'Mengupload...' : 'Selesai!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isUploading ? const Color(0xFF1A237E) : Colors.green,
                    ),
                  ),
                  Text('$_done / $_total', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isUploading ? const Color(0xFF1A237E) : Colors.green,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              if (_isUploading && _currentFile.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _currentFile,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Log
            if (_log.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.builder(
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Text(
                      _log[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: _log[i].startsWith('🎉')
                            ? Colors.green.shade700
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Tombol upload
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _startUpload,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(_isUploading
                    ? 'Mengupload $_done/$_total...'
                    : _uploadedUrls.isNotEmpty
                        ? 'Upload Ulang'
                        : 'Mulai Upload ke Firebase Storage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan koneksi internet stabil sebelum upload.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
