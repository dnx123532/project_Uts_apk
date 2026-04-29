// ─── BOOKING STATE (global singleton) ────────────────────────────────────────
// Menyimpan semua histori booking + notifikasi

class BookingItem {
  final String id;
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> seats;
  final int ticketPrice;
  final List<Map<String, dynamic>> foodOrder;
  final String paymentMethod;
  final int grandTotal;
  final DateTime bookedAt;

  BookingItem({
    required this.id,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.seats,
    required this.ticketPrice,
    required this.foodOrder,
    required this.paymentMethod,
    required this.grandTotal,
    required this.bookedAt,
  });
}
