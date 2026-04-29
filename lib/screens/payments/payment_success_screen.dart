import 'package:flutter/material.dart ';
import 'package:flutter_application_for_us/models/booking_model.dart';
import 'package:flutter_application_for_us/widgets/dashed_divider.dart';
import 'package:flutter_application_for_us/widgets/ticket_row.dart';

// ─── PAYMENT SUCCESS SCREEN ───────────────────────────────────────────────────
class PaymentSuccessScreen extends StatelessWidget {
  final BookingItem booking;
  const PaymentSuccessScreen({super.key, required this.booking});

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Animasi sukses
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tiket kamu sudah dikonfirmasi',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Tiket card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header tiket
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A237E),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    imagePath,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 60,
                                      height: 80,
                                      color: Colors.white24,
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        booking.cinemaName,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Garis putus-putus
                          DashedDivider(),

                          // Detail tiket
                          // Detail tiket (TIMPA KODE PADDING INI BG)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // TANGGAL TETAP MUNCUL UNTUK SEMUA PESANAN
                                TicketRow(
                                  label: 'Tanggal',
                                  value: _fmtDate(booking.date),
                                ),

                                // LOGIC PINTAR: INFO INI HANYA MUNCUL JIKA ADA TIKET FILM (KURSI TIDAK KOSONG)
                                if (booking.seats.isNotEmpty) ...[
                                  TicketRow(label: 'Jam', value: booking.time),
                                  TicketRow(
                                    label: 'Studio',
                                    value: booking.screenType.split(' ').first,
                                  ),
                                  TicketRow(
                                    label: 'Kursi',
                                    value: booking.seats.join(', '),
                                  ),
                                ],

                                // F&B SELALU MUNCUL JIKA ADA PESANAN MAKANAN
                                if (booking.foodOrder.isNotEmpty)
                                  TicketRow(
                                    label: 'F&B',
                                    value: booking.foodOrder
                                        .map((f) => '${f['name']} x${f['qty']}')
                                        .join(', '),
                                  ),

                                const Divider(height: 20),
                                TicketRow(
                                  label: 'Metode Bayar',
                                  value: booking.paymentMethod,
                                ),
                                TicketRow(
                                  label: 'Total',
                                  value: _fmt(booking.grandTotal),
                                  valueStyle: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Tombol ke home
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
