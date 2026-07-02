import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_uts_apk/screens/food_and_beverages/food_and_beverage_screen.dart';
import 'package:project_uts_apk/services/firestore_service.dart';
import 'package:project_uts_apk/widgets/app_image.dart';

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
  static const List<String> _rows = [
    'M','L','K','J','I','H','G','F','E','D','C','B','A',
  ];

  final FirestoreService _firestore = FirestoreService();

  Set<String> _bookedSeats = {};
  final Set<String> _selectedSeats = {};
  bool _isLoading = true;
  StreamSubscription<List<String>>? _seatSub;

  // Apakah jam tayang sudah lewat
  bool get _isPast {
    final parts = widget.time.split(':');
    final showtime = DateTime(
      widget.date.year, widget.date.month, widget.date.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );
    return showtime.isBefore(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _seatSub = _firestore
        .streamBookedSeats(widget.cinemaName, widget.date, widget.time)
        .listen(
      (seats) {
        if (mounted) {
          setState(() {
            _bookedSeats = seats.toSet();
            _isLoading = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _seatSub?.cancel();
    super.dispose();
  }

  // ── Helpers ──
  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]}, $dd.$mm.${d.year}';
  }

  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    return 'Rp ${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  int get _totalPrice => _selectedSeats.length * widget.price;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String title = (movie.title ?? '') as String;
    final String genre = ((movie.genre ?? '') as String).split(',').first.trim().toUpperCase();
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              '${_formatDate(widget.date)} - ${widget.time} | ${widget.screenType.split(' ').first}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBanner(),
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
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildBanner() {
    if (_isPast) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Jadwal ini sudah lewat — tidak bisa memesan kursi',
                style: TextStyle(fontSize: 13, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha:0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tiket yang dibeli tidak dapat diubah atau di refund',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfo(String title, String genre, String duration, String imagePath, double rating) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          AppImage(
            path: imagePath,
            width: 80,
            height: 105,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
            errorWidget: Container(
              width: 80, height: 105, color: Colors.grey.shade200,
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$genre • $duration', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(rating.toString(), style: const TextStyle(fontSize: 12)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1A237E).withValues(alpha:0.18), const Color(0xFF1A237E).withValues(alpha:0.04)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(60)),
            ),
            child: const Center(
              child: Text('SCREEN', style: TextStyle(fontSize: 12, color: Color(0xFF1A237E), fontWeight: FontWeight.bold, letterSpacing: 3)),
            ),
          ),
          const SizedBox(height: 6),
          const Text('STANDARD', style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isPast) ...[
          _LegendItem(color: const Color(0xFF1A237E), label: 'Tersedia'),
          const SizedBox(width: 16),
        ],
        _LegendItem(color: Colors.grey.shade400, label: 'Terisi'),
        if (!_isPast) ...[
          const SizedBox(width: 16),
          const _LegendItem(color: Colors.amber, label: 'Dipilih'),
        ],
        if (_isPast) ...[
          const SizedBox(width: 16),
          _LegendItem(color: Colors.grey.shade200, label: 'Lewat'),
        ],
      ],
    );
  }

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
                SizedBox(width: 20, child: Text(row, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
                const SizedBox(width: 4),
                ...List.generate(10, (i) => _buildSeat('$row${i + 1}', i + 1)),
                const SizedBox(width: 16),
                ...List.generate(10, (i) => _buildSeat('$row${i + 11}', i + 11)),
                const SizedBox(width: 4),
                SizedBox(width: 20, child: Text(row, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
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
    final isPast = _isPast;

    Color bgColor;
    Color textColor;

    if (isPast) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
    } else if (isBooked) {
      bgColor = Colors.grey.shade400;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = Colors.amber;
      textColor = Colors.black;
    } else {
      bgColor = const Color(0xFF1A237E);
      textColor = Colors.white;
    }

    final canTap = !isPast && !isBooked;

    return GestureDetector(
      onTap: canTap
          ? () => setState(() {
                if (isSelected) {
                  _selectedSeats.remove(seatId);
                } else {
                  _selectedSeats.add(seatId);
                }
              })
          : null,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text('$seatNum', style: TextStyle(fontSize: 8, color: textColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final sortedSeats = _selectedSeats.toList()..sort();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sortedSeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.event_seat_rounded, size: 16, color: Color(0xFF1A237E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(sortedSeats.join(', '),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A237E)),
                      overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    _isPast
                        ? 'Jadwal lewat'
                        : sortedSeats.isEmpty
                            ? 'Pilih kursi'
                            : _formatPrice(_totalPrice),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  if (sortedSeats.isNotEmpty)
                    Text('${sortedSeats.length} kursi × ${_formatPrice(widget.price)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_isPast || sortedSeats.isEmpty)
                    ? null
                    : () => Navigator.push(
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
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Beli Tiket', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
