import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/cinema_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/seed_service.dart';

class CinemaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FirestoreService _firestore = FirestoreService();

  Map<String, List<CinemaSchedule>> _cinemas = {};
  bool _isLoading = false;

  Map<String, List<CinemaSchedule>> get cinemas => _cinemas;
  bool get isLoading => _isLoading;

  CinemaProvider() {
    // Tampilkan seed data langsung tanpa loading
    _cinemas = SeedService.cinemaData;
    // Refresh dari network di background (silent)
    _refreshFromNetwork();
  }

  Future<void> _refreshFromNetwork() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) return;

      // Coba API dulu, timeout 6 detik
      try {
        final data = await _api.fetchCinemas().timeout(const Duration(seconds: 6));
        if (data.isNotEmpty) {
          _cinemas = data;
          notifyListeners();
          _firestore.saveCinemas(data).catchError((_) {});
          return;
        }
      } catch (_) {}

      // Fallback ke Firestore, timeout 6 detik
      try {
        final fsData = await _firestore.getCinemas().timeout(const Duration(seconds: 6));
        if (fsData.isNotEmpty) {
          _cinemas = fsData;
          notifyListeners();
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> loadCinemas() async {
    _isLoading = true;
    notifyListeners();
    await _refreshFromNetwork();
    _isLoading = false;
    notifyListeners();
  }

  List<CinemaSchedule> getByCity(String city) {
    return _cinemas[city] ?? _cinemas['Medan'] ?? [];
  }
}
