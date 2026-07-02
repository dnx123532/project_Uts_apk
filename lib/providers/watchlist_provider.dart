import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class WatchlistState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<String> _titles = [];
  int _seenCount = 0; // jumlah yang sudah dilihat user

  List<String> get titles => List.unmodifiable(_titles);

  // Badge hanya muncul kalau ada film baru sejak terakhir buka watchlist
  int get unreadCount => (_titles.length - _seenCount).clamp(0, 999);

  WatchlistState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _load(user.uid);
      } else {
        _titles = [];
        _seenCount = 0;
        notifyListeners();
      }
    });
  }

  bool isInWatchlist(String title) => _titles.contains(title);

  Future<void> toggle(String title) async {
    if (_titles.contains(title)) {
      _titles.remove(title);
      // kalau hapus, sesuaikan seenCount supaya badge tidak salah hitung
      if (_seenCount > _titles.length) _seenCount = _titles.length;
    } else {
      _titles.add(title);
    }
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _firestore.saveWatchlist(uid, _titles).catchError((_) {});
    }
  }

  // Dipanggil saat user buka WatchlistScreen
  void markAsSeen() {
    _seenCount = _titles.length;
    notifyListeners();
  }

  Future<void> _load(String uid) async {
    try {
      _titles = await _firestore.getWatchlist(uid);
      _seenCount = _titles.length; // data lama dianggap sudah dilihat
      notifyListeners();
    } catch (_) {}
  }
}
