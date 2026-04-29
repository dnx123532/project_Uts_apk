import 'package:flutter/material.dart ';
import 'package:flutter_application_for_us/models/booking_model.dart';
import 'package:flutter_application_for_us/widgets/icon_text_row.dart';
import 'package:flutter_application_for_us/widgets/ticket_row.dart';
import 'package:flutter_application_for_us/widgets/white_card.dart';

// ─── BOOKING DETAIL SCREEN ────────────────────────────────────────────────────
class BookingDetailScreen extends StatelessWidget {
  final BookingItem booking;
  const BookingDetailScreen({super.key, required this.booking});

  String _fmt(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _fmtDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]}, $dd.$mm.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String title = (booking.movie.title ?? '') as String;
    final String imagePath = (booking.movie.imagePath ?? '') as String;
    final int ticketTotal = booking.seats.length * booking.ticketPrice;
    int foodTotal = 0;
    for (final f in booking.foodOrder) {
      foodTotal += (f['price'] as int) * (f['qty'] as int);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Film info card
            WhiteCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 110,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        InfoRow2(
                          icon: Icons.theaters_outlined,
                          text: booking.cinemaName,
                        ),

                        // --- LOGIC F&B ---
                        if (booking.seats.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          InfoRow2(
                            icon: Icons.confirmation_number_outlined,
                            text: booking.screenType,
                          ),
                          const SizedBox(height: 5),
                          InfoRow2(
                            icon: Icons.calendar_today_outlined,
                            text: '${_fmtDate(booking.date)} • ${booking.time}',
                          ),
                          const SizedBox(height: 5),
                          InfoRow2(
                            icon: Icons.event_seat_outlined,
                            text: 'Kursi: ${booking.seats.join(', ')}',
                          ),
                        ] else ...[
                          // Kalau cuma F&B, tampilkan tanggal saja
                          const SizedBox(height: 5),
                          InfoRow2(
                            icon: Icons.calendar_today_outlined,
                            text: '${_fmtDate(booking.date)} • Pesanan F&B',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // F&B jika ada
            if (booking.foodOrder.isNotEmpty)
              WhiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food & Beverages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...booking.foodOrder.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fastfood_rounded,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${f['name']} x${f['qty']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              _fmt((f['price'] as int) * (f['qty'] as int)),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (booking.foodOrder.isNotEmpty) const SizedBox(height: 14),

            // Ringkasan pembayaran
            // Ringkasan pembayaran
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  // Harga tiket hanya muncul kalau beneran beli tiket
                  if (booking.seats.isNotEmpty)
                    TicketRow(
                      label: '${booking.seats.length} Tiket',
                      value: _fmt(ticketTotal),
                    ),

                  if (foodTotal > 0)
                    TicketRow(label: 'F&B', value: _fmt(foodTotal)),

                  // Biaya layanan untuk tiket
                  if (booking.seats.isNotEmpty)
                    const TicketRow(label: 'Biaya Layanan', value: 'Rp 3,500'),

                  const Divider(height: 16),
                  TicketRow(
                    label: 'Total Pembayaran',
                    value: _fmt(booking.grandTotal),
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TicketRow(
                    label: 'Metode Bayar',
                    value: booking.paymentMethod,
                  ),
                  const TicketRow(
                    label: 'Status',
                    value: 'Berhasil',
                    valueStyle: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
