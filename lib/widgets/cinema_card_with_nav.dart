import 'package:flutter/material.dart';
import 'package:project_uts_apk/screens/Seats/seat_selection_screen.dart';
// import '../models/cinema_model.dart';

// ─── CINEMA CARD WITH NAV ─────────────────────────────────────────────────────
class CinemaCardWithNav extends StatefulWidget {
  final dynamic cinema;
  final dynamic movie;
  final DateTime selectedDate;

  const CinemaCardWithNav({
    super.key,
    required this.cinema,
    required this.movie,
    required this.selectedDate,
  });

  @override
  State<CinemaCardWithNav> createState() => _CinemaCardWithNavState();
}

class _CinemaCardWithNavState extends State<CinemaCardWithNav> {
  String? _selectedTime;

  bool _isTimePast(String time) {
    final parts = time.split(':');
    final showtime = DateTime(
      widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );
    return showtime.isBefore(DateTime.now());
  }

  String _formatPrice(int price) {
    final s = price.toString();
    if (s.length <= 3) return 'Rp $s';
    return 'Rp ${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final cinema = widget.cinema;
    final List<String> times = List<String>.from(cinema.times as List);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cinema.cinemaName as String,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen type & harga
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cinema.screenType as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatPrice(cinema.price as int),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Daftar waktu — hanya 1 yang bisa dipilih
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((time) {
                  final isSelected = _selectedTime == time;
                  final isPast = _isTimePast(time);

                  return GestureDetector(
                    onTap: isPast
                        ? null
                        : () {
                            setState(() => _selectedTime = time);
                            final nav = Navigator.of(context);
                            Future.delayed(const Duration(milliseconds: 150), () {
                              if (!mounted) return;
                              nav.push(
                                MaterialPageRoute(
                                  builder: (_) => SeatSelectionScreen(
                                    movie: widget.movie,
                                    cinemaName: cinema.cinemaName as String,
                                    screenType: cinema.screenType as String,
                                    price: cinema.price as int,
                                    time: time,
                                    date: widget.selectedDate,
                                  ),
                                ),
                              ).then((_) {
                                if (mounted) setState(() => _selectedTime = null);
                              });
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.grey.shade100
                            : isSelected
                                ? const Color(0xFF1A237E)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPast
                              ? Colors.grey.shade200
                              : isSelected
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isPast
                              ? Colors.grey.shade400
                              : isSelected
                                  ? Colors.white
                                  : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
