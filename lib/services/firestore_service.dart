import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_models.dart';
import '../models/food_model.dart';
import '../models/cinema_model.dart';
import '../models/booking_model.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── MOVIES ──────────────────────────────────────────────────────────────────

  Future<void> saveMovies(List<MovieModel> movies) async {
    final batch = _db.batch();
    for (var movie in movies) {
      final ref = _db.collection('movies').doc(movie.title);
      batch.set(ref, movie.toMap());
    }
    await batch.commit();
  }

  Future<List<MovieModel>> getMovies() async {
    final snapshot = await _db.collection('movies').get();
    return snapshot.docs
        .map((doc) => MovieModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> addMovie(MovieModel movie) async {
    await _db.collection('movies').doc(movie.title).set(movie.toMap());
  }

  Future<void> deleteMovie(String title) async {
    await _db.collection('movies').doc(title).delete();
  }

  // ── FOOD ITEMS ───────────────────────────────────────────────────────────────

  Future<void> saveFoodItems(List<FoodItem> items) async {
    final batch = _db.batch();
    for (var item in items) {
      final ref = _db.collection('food_items').doc(item.id);
      batch.set(ref, item.toMap());
    }
    await batch.commit();
  }

  Future<List<FoodItem>> getFoodItems() async {
    final snapshot = await _db.collection('food_items').get();
    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data()))
        .toList();
  }

  // ── CINEMAS ──────────────────────────────────────────────────────────────────

  Future<void> saveCinemas(Map<String, List<CinemaSchedule>> cinemas) async {
    final batch = _db.batch();
    cinemas.forEach((city, schedules) {
      final ref = _db.collection('cinemas').doc(city);
      batch.set(ref, {
        'schedules': schedules.map((s) => s.toMap()).toList(),
      });
    });
    await batch.commit();
  }

  Future<Map<String, List<CinemaSchedule>>> getCinemas() async {
    final snapshot = await _db.collection('cinemas').get();
    final Map<String, List<CinemaSchedule>> result = {};
    for (var doc in snapshot.docs) {
      final raw = doc.data()['schedules'] as List? ?? [];
      result[doc.id] = raw
          .map((s) => CinemaSchedule.fromMap(Map<String, dynamic>.from(s)))
          .toList();
    }
    return result;
  }

  // ── SEAT BOOKINGS (per sesi: cinema + tanggal + jam) ────────────────────────

  String _seatKey(String cinemaName, DateTime date, String time) {
    final d = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final t = time.replaceAll(':', '');
    return '${cinemaName}_${d}_$t'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  Future<List<String>> getBookedSeats(String cinemaName, DateTime date, String time) async {
    final doc = await _db.collection('seat_bookings').doc(_seatKey(cinemaName, date, time)).get();
    if (!doc.exists) return [];
    return List<String>.from(doc.data()?['seats'] ?? []);
  }

  // Real-time stream — langsung update kalau ada user lain booking
  Stream<List<String>> streamBookedSeats(String cinemaName, DateTime date, String time) {
    return _db
        .collection('seat_bookings')
        .doc(_seatKey(cinemaName, date, time))
        .snapshots()
        .map((doc) {
      if (!doc.exists) return <String>[];
      return List<String>.from(doc.data()?['seats'] ?? []);
    });
  }

  Future<void> addBookedSeats(String cinemaName, DateTime date, String time, List<String> seats) async {
    await _db.collection('seat_bookings').doc(_seatKey(cinemaName, date, time)).set({
      'seats': FieldValue.arrayUnion(seats),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── BOOKINGS (per user) ──────────────────────────────────────────────────────

  Future<void> saveBooking(String uid, BookingItem booking) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toMap());
  }

  // ── WATCHLIST (per user) ─────────────────────────────────────────────────────

  Future<void> saveWatchlist(String uid, List<String> titles) async {
    await _db.collection('users').doc(uid).set(
      {'watchlist': titles},
      SetOptions(merge: true),
    );
  }

  Future<List<String>> getWatchlist(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return List<String>.from(doc.data()?['watchlist'] ?? []);
  }

  // ── BOOKINGS (per user) ──────────────────────────────────────────────────────

  Future<List<BookingItem>> getUserBookings(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => BookingItem.fromMap(doc.data()))
        .toList();
  }

  // ── CHAT HISTORY (per user) ──────────────────────────────────────────────────

  Future<List<ChatMessage>> getChatHistory(String uid) async {
    final doc = await _db.collection('chats').doc(uid).get();
    if (!doc.exists) return [];
    final raw = doc.data()?['messages'] as List<dynamic>? ?? [];
    return raw
        .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  Future<void> saveChatHistory(String uid, List<ChatMessage> messages) async {
    // Simpan maksimal 100 pesan terakhir agar tidak melebihi batas Firestore
    final trimmed = messages.length > 100
        ? messages.sublist(messages.length - 100)
        : messages;
    await _db.collection('chats').doc(uid).set({
      'messages': trimmed.map((m) => m.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearChatHistory(String uid) async {
    await _db.collection('chats').doc(uid).delete();
  }
}
