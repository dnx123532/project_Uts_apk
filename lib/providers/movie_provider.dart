import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/movie_models.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  final FirestoreService _firestoreService = FirestoreService();

  List<MovieModel> _movies = [];
  String _errorMessage = '';
  bool _isOffline = false;

  List<MovieModel> get movies => _movies;
  bool get isLoading => false;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  MovieProvider() {
    // 1. Load SQLite cache dulu (lokal, cepat, tidak butuh internet)
    _loadCachedThenRefresh();
  }

  Future<void> _loadCachedThenRefresh() async {
    // Load SQLite cache — instan, tidak perlu connectivity
    final cached = await _dbService.getCachedMovies();
    if (cached.isNotEmpty) {
      _movies = cached;
      notifyListeners();
    }
    // Setelah cache tampil, cek internet lalu refresh di background
    await loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      _isOffline = !hasInternet;

      if (!hasInternet) {
        // OFFLINE: pakai SQLite cache yang sudah ditampilkan
        if (_movies.isEmpty) {
          _errorMessage = 'Anda offline dan tidak ada data tersimpan.';
          notifyListeners();
        }
        return;
      }

      // Ambil dari Firestore sebagai sumber utama (timeout 8 detik)
      try {
        final fsMovies = await _firestoreService.getMovies().timeout(
          const Duration(seconds: 8),
        );
        if (fsMovies.isNotEmpty) {
          _movies = fsMovies;
          _errorMessage = '';
          notifyListeners();
          _dbService.cacheMovies(fsMovies).catchError((_) {}); // Update SQLite
          return;
        }
      } catch (_) {}

      // Fallback ke API jika Firestore kosong/gagal
      try {
        final fetched = await _apiService.fetchMovies().timeout(
          const Duration(seconds: 6),
        );
        if (fetched.isNotEmpty) {
          _movies = fetched;
          _errorMessage = '';
          notifyListeners();
          _dbService.cacheMovies(fetched).catchError((_) {});
        }
      } catch (_) {}
    } catch (e) {
      _isOffline = true;
      if (_movies.isEmpty) {
        _errorMessage = 'Terjadi kesalahan sistem.';
        notifyListeners();
      }
    }
  }
}
