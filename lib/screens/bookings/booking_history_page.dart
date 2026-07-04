import 'package:flutter/material.dart ';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/models/booking_model.dart';
import 'package:project_uts_apk/providers/movie_provider.dart';
import 'package:project_uts_apk/screens/bookings/booking.dart';
import 'package:project_uts_apk/widgets/app_image.dart';
import 'package:provider/provider.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  bool _isPast(BookingItem b) {
    if (b.seats.isEmpty) {
      // F&B only — cek tanggal saja
      return b.date.isBefore(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day,
      ));
    }
    final parts = b.time.split(':');
    final showtime = DateTime(
      b.date.year, b.date.month, b.date.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );
    return showtime.isBefore(DateTime.now());
  }

  String _fmtDate(DateTime d) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]}, $dd/$mm/${d.year}';
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header + Tab ──────────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Tiket Saya',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                ),
              ),
              TabBar(
                controller: _tab,
                labelColor: const Color(0xFF1A237E),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1A237E),
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'Mendatang'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ],
          ),
        ),

        // ── Tab Content ───────────────────────────────────────────────────
        Expanded(
          child: AnimatedBuilder(
            animation: bookingState,
            builder: (context, _) {
              final all = bookingState.bookings.toList();
              final upcoming = all.where((b) => !_isPast(b)).toList();
              final history = all.where((b) => _isPast(b)).toList();

              // Map judul → CDN imagePath dari MovieProvider
              final movies = context.read<MovieProvider>().movies;
              final Map<String, String> imageMap = {
                for (final m in movies) m.title.toLowerCase(): m.imagePath,
              };

              return TabBarView(
                controller: _tab,
                children: [
                  _buildList(upcoming, isHistory: false, imageMap: imageMap),
                  _buildList(history, isHistory: true, imageMap: imageMap),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<BookingItem> bookings, {required bool isHistory, required Map<String, String> imageMap}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.history : Icons.confirmation_number_outlined,
              size: 64,
              color: const Color(0xFF1A237E).withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              isHistory ? 'Belum ada riwayat' : 'Belum ada tiket mendatang',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 8),
            Text(
              isHistory ? 'Pesanan yang sudah lewat akan tampil di sini' : 'Pesan tiket film pertamamu sekarang!',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        final String title = (b.movie.title ?? '') as String;
        final String storedPath = (b.movie.imagePath ?? '') as String;
        // Gunakan CDN URL dari MovieProvider, fallback ke path tersimpan
        final String imagePath = imageMap[title.toLowerCase()] ?? storedPath;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: b)),
          ),
          child: Opacity(
            opacity: isHistory ? 0.65 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Poster
                  AppImage(
                    path: imagePath,
                    width: 90,
                    height: 120,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    errorWidget: Container(
                      width: 90,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(b.cinemaName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            b.seats.isEmpty
                                ? '${_fmtDate(b.date)}  •  Pesanan F&B'
                                : '${_fmtDate(b.date)}  •  ${b.time}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isHistory
                                      ? Colors.grey.withValues(alpha: 0.12)
                                      : Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isHistory ? 'Selesai' : 'Aktif',
                                  style: TextStyle(
                                    color: isHistory ? Colors.grey : Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _fmt(b.grandTotal),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
