import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';

class BookingState extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _db = DatabaseService();

  final List<BookingItem> _bookings = [];
  final List<String> _notifications = [];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);
  List<String> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  BookingState() {
    // Auto-load saat login, clear saat logout
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadBookings(user.uid);
      } else {
        _clearAll();
      }
    });
  }

  Future<void> _loadBookings(String uid) async {
    try {
      // Online: ambil dari Firestore, cache ke SQLite
      final data = await _firestore.getUserBookings(uid);
      _bookings
        ..clear()
        ..addAll(data);
      // Sync ke SQLite sebagai cache offline
      for (final b in data) {
        _db.saveBooking(uid, b).catchError((_) {});
      }
    } catch (_) {
      // Offline: ambil dari SQLite
      try {
        final cached = await _db.getCachedBookings(uid);
        _bookings
          ..clear()
          ..addAll(cached);
      } catch (_) {}
    }
    notifyListeners();
  }

  void _clearAll() {
    _bookings.clear();
    _notifications.clear();
    notifyListeners();
  }

  Future<void> addBooking(BookingItem item) async {
    _bookings.insert(0, item);

    final message = item.seats.isEmpty
        ? 'Pesanan F&B berhasil! Yuk ambil di counter snack.'
        : 'Pemesanan berhasil! ${item.movie.title} - ${item.seats.join(', ')}';
    _notifications.insert(0, message);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Simpan booking ke Firestore + SQLite
      _firestore.saveBooking(uid, item).catchError((_) {});
      _db.saveBooking(uid, item).catchError((_) {});
    }

    // Tandai kursi sebagai terisi di Firestore (visible ke semua user)
    if (item.seats.isNotEmpty) {
      _firestore.addBookedSeats(
        item.cinemaName, item.date, item.time, item.seats,
      ).catchError((_) {});
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
