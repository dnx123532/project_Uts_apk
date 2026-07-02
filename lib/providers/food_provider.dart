import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/food_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';
import '../services/seed_service.dart';

class FoodProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _db = DatabaseService();

  List<FoodItem> _foodItems = [];
  bool _isLoading = false;

  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;

  FoodProvider() {
    // 1. Seed data tampil instan
    _foodItems = SeedService.foodItems;
    // 2. Load SQLite cache (lokal, cepat), lalu refresh dari network
    _loadCachedThenRefresh();
  }

  Future<void> _loadCachedThenRefresh() async {
    // Load SQLite cache dulu — tidak butuh internet
    final cached = await _db.getCachedFoodItems();
    if (cached.isNotEmpty) {
      _foodItems = cached;
      notifyListeners();
    }
    // Setelah cache tampil, cek internet lalu refresh
    await _refreshFromNetwork();
  }

  Future<void> _refreshFromNetwork() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) return; // Offline, pakai cache/seed

      // Coba API dulu, timeout 6 detik
      try {
        final items = await _api.fetchFoodItems().timeout(const Duration(seconds: 6));
        if (items.isNotEmpty) {
          _foodItems = items;
          notifyListeners();
          _db.cacheFoodItems(items).catchError((_) {}); // Simpan ke SQLite
          _firestore.saveFoodItems(items).catchError((_) {});
          return;
        }
      } catch (_) {}

      // Fallback ke Firestore, timeout 6 detik
      try {
        final items = await _firestore.getFoodItems().timeout(const Duration(seconds: 6));
        if (items.isNotEmpty) {
          _foodItems = items;
          notifyListeners();
          _db.cacheFoodItems(items).catchError((_) {}); // Simpan ke SQLite
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> loadFoodItems() async {
    _isLoading = true;
    notifyListeners();
    await _refreshFromNetwork();
    _isLoading = false;
    notifyListeners();
  }

}
