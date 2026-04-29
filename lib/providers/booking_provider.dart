import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingState extends ChangeNotifier {
  final List<BookingItem> _bookings = [];
  final List<String> _notifications = [];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);
  List<String> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  // Di dalam class BookingState
  void addBooking(BookingItem item) {
    _bookings.insert(0, item);

    // Logic Notif Pintar: Cek apakah beli tiket atau cuma makanan
    String message = item.seats.isEmpty
        ? 'Pesanan F&B berhasil! Yuk ambil di counter snack.'
        : 'Pemesanan berhasil! ${item.movie.title} - ${item.seats.join(', ')}';

    _notifications.insert(0, message);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
