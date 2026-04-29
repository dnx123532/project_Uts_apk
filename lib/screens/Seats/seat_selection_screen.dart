import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/screens/food_and_beverages/food_and_beverage_screen.dart';

// ─── SEAT SELECTION SCREEN ────────────────────────────────────────────────────
class SeatSelectionScreen extends StatefulWidget {
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final int price;
  final String time;
  final DateTime date;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.price,
    required this.time,
    required this.date,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Baris A-M (13 baris), tiap baris 20 kursi
  static const List<String> _rows = [
    'M',
    'L',
    'K',
    'J',
    'I',
    'H',
    'G',
    'F',
    'E',
    'D',
    'C',
    'B',
    'A',
  ];

  // Kursi yang sudah terisi (simulasi acak)
  final Set<String> _bookedSeats = {
    'A4',
    'A5',
    'A6',
    'B8',
    'B9',
    'C12',
    'C13',
    'C14',
    'D3',
    'D4',
    'E7',
    'E8',
    'E9',
    'E10',
    'F15',
    'F16',
    'G5',
    'G6',
    'H11',
    'H12',
    'H13',
    'I2',
    'I3',
    'J18',
    'J19',
    'K7',
    'K8',
    'K9',
    'L14',
    'L15',
    'M1',
    'M2',
  };

  // Kursi yang dipilih user
  final Set<String> _selectedSeats = {};

  // ── Helper ──
  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[d.weekday - 1];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$day, $dd.$mm.${d.year}';
  }

  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    return 'Rp ${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  int get _totalPrice => _selectedSeats.length * widget.price;

  String _getYear(String title) {
    final t = title.toLowerCase();
    if (t.contains('endgame')) return '2019';
    if (t.contains('chainsaw')) return '2024';
    if (t.contains('dark knight')) return '2008';
    if (t.contains('look back')) return '2024';
    if (t.contains('one for all') || t.contains('merah putih')) return '2025';
    if (t.contains('jujutsu')) return '2021';
    if (t.contains('now you see me')) return '2013';
    if (t.contains('conjuring')) return '2013';
    if (t.contains('toy story')) return '2019';
    if (t.contains('infinity war')) return '2018';
    return '2025';
  }

  String _getAgeRating(String title) {
    final t = title.toLowerCase();
    if (t.contains('conjuring') ||
        t.contains('chainsaw') ||
        t.contains('dark knight')) {
      return 'D17';
    }
    if (t.contains('toy story') || t.contains('look back')) return 'SU';
    return 'D13';
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String title = (movie.title ?? '') as String;
    final String genre = ((movie.genre ?? '') as String)
        .split(',')
        .first
        .trim()
        .toUpperCase();
    final String duration = (movie.duration ?? '') as String;
    final String imagePath = (movie.imagePath ?? '') as String;
    final double rating = (movie.rating ?? 0.0) as double;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cinemaName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '${_formatDate(widget.date)} - ${widget.time} | ${widget.screenType.split(' ').first}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Konten scroll ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNotifBanner(),
                  _buildMovieInfo(title, genre, duration, imagePath, rating),
                  _buildScreenIndicator(),
                  const SizedBox(height: 12),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  _buildSeatGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ── Bottom bar ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Banner peringatan ──
  Widget _buildNotifBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tiket yang dibeli tidak dapat diubah atau di refund',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Icon(Icons.close, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }

  // ── Info film ──
  Widget _buildMovieInfo(
    String title,
    String genre,
    String duration,
    String imagePath,
    double rating,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80,
                height: 105,
                color: Colors.grey.shade200,
                child: const Icon(Icons.movie, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$genre • $duration',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // Tahun | Age | IDN | Rating
                Wrap(
                  spacing: 0,
                  children: [
                    Text(_getYear(title), style: const TextStyle(fontSize: 12)),
                    _pipe(),
                    Text(
                      _getAgeRating(title),
                      style: const TextStyle(fontSize: 12),
                    ),
                    _pipe(),
                    const Text('IDN', style: TextStyle(fontSize: 12)),
                    _pipe(),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pipe() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 1,
      height: 12,
      color: Colors.grey.shade300,
    );
  }

  // ── Screen indicator ──
  Widget _buildScreenIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.18),
                  const Color(0xFF1A237E).withOpacity(0.04),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(60),
              ),
            ),
            child: const Center(
              child: Text(
                'SCREEN',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'STANDARD',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Legend ──
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF1A237E), label: 'Tersedia'),
        const SizedBox(width: 20),
        _LegendItem(color: Colors.grey.shade400, label: 'Terisi'),
        const SizedBox(width: 20),
        const _LegendItem(color: Colors.amber, label: 'Dipilih'),
      ],
    );
  }

  // ── Seat Grid ──
  Widget _buildSeatGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: _rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                // Label baris kiri
                SizedBox(
                  width: 20,
                  child: Text(
                    row,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Kursi 1-10 (kiri)
                ...List.generate(10, (i) => _buildSeat('$row${i + 1}', i + 1)),
                // Gang tengah
                const SizedBox(width: 16),
                // Kursi 11-20 (kanan)
                ...List.generate(
                  10,
                  (i) => _buildSeat('$row${i + 11}', i + 11),
                ),
                const SizedBox(width: 4),
                // Label baris kanan
                SizedBox(
                  width: 20,
                  child: Text(
                    row,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeat(String seatId, int seatNum) {
    final isBooked = _bookedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);

    final Color bgColor;
    final Color textColor;

    if (isBooked) {
      bgColor = Colors.grey.shade400;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = Colors.amber;
      textColor = Colors.black;
    } else {
      bgColor = const Color(0xFF1A237E);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(seatId);
                } else {
                  _selectedSeats.add(seatId);
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '$seatNum',
            style: TextStyle(
              fontSize: 8,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    final sortedSeats = _selectedSeats.toList()..sort();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tampilkan kursi terpilih
          if (sortedSeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_seat_rounded,
                    size: 16,
                    color: Color(0xFF1A237E),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sortedSeats.join(', '),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A237E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // Info harga
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    sortedSeats.isEmpty
                        ? 'Pilih kursi'
                        : _formatPrice(_totalPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  if (sortedSeats.isNotEmpty)
                    Text(
                      '${sortedSeats.length} kursi × ${_formatPrice(widget.price)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
              const Spacer(),
              // Tombol beli
              ElevatedButton(
                onPressed: sortedSeats.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodBeveragesScreen(
                              movie: widget.movie,
                              cinemaName: widget.cinemaName,
                              screenType: widget.screenType,
                              time: widget.time,
                              date: widget.date,
                              selectedSeats: sortedSeats,
                              ticketPrice: widget.price,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Beli Tiket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── LEGEND ITEM ──────────────────────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
