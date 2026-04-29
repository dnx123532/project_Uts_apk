// ─── NOTIFICATION SCREEN ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/screens/payments/payment_process_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: bookingState,
        builder: (context, _) {
          // Kita ambil data tiket dari bookings aja biar infonya lengkap
          final bookings = bookingState.bookings;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: const Color(0xFF1A237E).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pesan tiket film pertamamu sekarang!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final title = (b.movie.title ?? '') as String;

              // Format tanggal untuk nampilin "kapan notif masuk" (simulasi)
              final d = b.bookedAt;
              final timeStr =
                  '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon sukses
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Detail text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pembelian Tiket Berhasil!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Cari di NotificationScreen bagian RichText:
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.4,
                              ),
                              children: b.seats.isEmpty
                                  ? [
                                      const TextSpan(text: 'Pesanan '),
                                      const TextSpan(
                                        text: 'F&B kamu ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: 'di '),
                                      TextSpan(
                                        text: b.cinemaName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' sudah dikonfirmasi. Selamat menikmati!',
                                      ),
                                    ]
                                  : [
                                      const TextSpan(
                                        text: 'Hore! Kamu berhasil membeli ',
                                      ),
                                      TextSpan(
                                        text: '${b.seats.length} tiket',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' untuk film '),
                                      TextSpan(
                                        text: title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '. Selamat menonton!',
                                      ),
                                    ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
