import 'dart:async';
import 'package:flutter/material.dart';
import 'payment_screen.dart';

// ─── SEAT SELECTION SCREEN 
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
  static const int _cols = 20;

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
    return '$day, $dd.${mm}.${d.year}';
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
        t.contains('dark knight'))
      return 'D17';
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
              errorBuilder: (_, __, ___) => Container(
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

// ─── LEGEND ITEM 
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

// ─── CINEMA CARD WITH NAV 

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
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTime = time);
                      // Delay sedikit biar animasi selected kelihatan
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (!mounted) return;
                        Navigator.push(
                          context,
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
                          // Reset setelah kembali dari seat selection
                          if (mounted) setState(() => _selectedTime = null);
                        });
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A237E)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A237E)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
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

// ─── DATA MODEL MAKANAN 
class FoodItem {
  final String id;
  final String name;
  final String
  category; // 'recommended', 'exclusive_combo', 'combo', 'snack', 'drink'
  final int price;
  final String imagePath; // kosong jika belum ada gambar
  final String? description;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath = '',
    this.description,
  });
}

// ── DATA MAKANAN — ISI SESUAI MENU 
// Ganti list di bawah ini dengan menu yang sebenarnya
final List<FoodItem> _allFoodItems = [
  // RECOMMENDED (muncul di bagian atas jika ada item di cart)
  FoodItem(
    id: 'rec_001',
    name: 'Paket Hemat Spesial',
    category: 'recommended',
    price: 85000,
    imagePath:
        'assets/images/Combo_1.png', // ganti dengan path gambar, e.g. 'assets/food/paket_hemat.png'
    description: 'Popcorn medium + 2 minuman',
  ),

  // EXCLUSIVE COMBO
  FoodItem(
    id: 'exc_001',
    name: 'Online Exclusive Combo Sweet',
    category: 'exclusive_combo',
    price: 104000,
    imagePath:
        'assets/images/online_exclusive combo _sweeet.png', // ganti dengan path gambar
    description: 'Popcorn large + 2 Coca-Cola + Pocky + Nugget',
  ),
  FoodItem(
    id: 'exc_002',
    name: 'Online Exclusive Combo Savory',
    category: 'exclusive_combo',
    price: 99000,
    imagePath: 'assets/images/combo_savory.png', // ganti dengan path gambar
    description: 'Popcorn large + 2 Coca-Cola + Chicken Strip',
  ),
  FoodItem(
    id: 'exc_003',
    name: 'Online Exclusive Combo Duo',
    category: 'exclusive_combo',
    price: 119000,
    imagePath:
        'assets/images/online_exclusive_combo_2.png', // ganti dengan path gambar
    description: 'Popcorn XL + 2 Coca-Cola + Snack pilihan',
  ),

  // COMBO
  FoodItem(
    id: 'cmb_001',
    name: 'Combo 1 - Popcorn + Minuman',
    category: 'combo',
    price: 65000,
    imagePath:
        'assets/images/Combo1_Popcorn_ Minuman.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'cmb_002',
    name: 'Combo 2 - Popcorn Besar + 2 Minuman',
    category: 'combo',
    price: 79000,
    imagePath:
        'assets/images/Combo_2_Popcorn_Besar_2_Minuman.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'cmb_003',
    name: 'Combo 3 - Family Pack',
    category: 'combo',
    price: 145000,
    imagePath:
        'assets/images/Combo 3_Family_Pack.png', // ganti dengan path gambar
  ),

  // SNACK
  FoodItem(
    id: 'snk_001',
    name: 'Popcorn Small',
    category: 'snack',
    price: 32000,
    imagePath: 'assets/images/Popcorn_Small.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_002',
    name: 'Popcorn Medium',
    category: 'snack',
    price: 42000,
    imagePath: 'assets/images/Popcorn_Medium.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_003',
    name: 'Popcorn Large',
    category: 'snack',
    price: 55000,
    imagePath: 'assets/images/Popcorn_Large.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_004',
    name: 'Nachos + Cheese',
    category: 'snack',
    price: 38000,
    imagePath: 'assets/images/Nachos_+_Cheese.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_005',
    name: 'Hot Dog',
    category: 'snack',
    price: 35000,
    imagePath: 'assets/images/HotDog.png', // ganti dengan path gambar
  ),

  // DRINK
  FoodItem(
    id: 'drk_001',
    name: 'Coca-Cola Regular',
    category: 'drink',
    price: 22000,
    imagePath:
        'assets/images/Coca-Cola_Regular.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_002',
    name: 'Coca-Cola Large',
    category: 'drink',
    price: 28000,
    imagePath: 'assets/images/Coca-Cola_Large.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_003',
    name: 'Air Mineral',
    category: 'drink',
    price: 15000,
    imagePath: 'assets/images/Air_Mineral.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_004',
    name: 'Juice Jeruk',
    category: 'drink',
    price: 30000,
    imagePath: 'assets/images/Juice_Jeruk.png', // ganti dengan path gambar
  ),
];

// ─── FOOD & BEVERAGES SCREEN 
class FoodBeveragesScreen extends StatefulWidget {
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> selectedSeats;
  final int ticketPrice;

  const FoodBeveragesScreen({
    super.key,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.selectedSeats,
    required this.ticketPrice,
  });

  @override
  State<FoodBeveragesScreen> createState() => _FoodBeveragesScreenState();
}

class _FoodBeveragesScreenState extends State<FoodBeveragesScreen> {
  // Cart: id -> qty
  final Map<String, int> _cart = {};

  // Countdown timer (5 menit)
  static const int _totalSeconds = 5 * 60;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  // Recommended item (item pertama di cart, atau default)
  String? _recommendedId;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Default recommended item
    final recs = _allFoodItems
        .where((f) => f.category == 'recommended')
        .toList();
    if (recs.isNotEmpty) _recommendedId = recs.first.id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        // Kembali ke home jika timeout
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // ── Helpers ──
  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    final len = s.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}.${(d.month).toString().padLeft(2, '0')}.${d.year}';
  }

  // Nama cinema tanpa nama kota
  String get _cinemaShort {
    final parts = widget.cinemaName.split(' ');
    if (parts.length <= 2) return widget.cinemaName;
    return parts.sublist(1).join(' ');
  }

  int get _totalFoodPrice {
    int total = 0;
    _cart.forEach((id, qty) {
      final item = _allFoodItems.firstWhere(
        (f) => f.id == id,
        orElse: () => FoodItem(id: '', name: '', category: '', price: 0),
      );
      total += item.price * qty;
    });
    return total;
  }

  int get _ticketTotal => widget.selectedSeats.length * widget.ticketPrice;
  int get _grandTotal => _ticketTotal + _totalFoodPrice;

  bool get _hasItemInCart => _cart.values.any((q) => q > 0);

  void _addToCart(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if ((_cart[id] ?? 0) <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]! - 1;
      }
    });
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String title = (movie.title ?? '') as String;
    final String imagePath = (movie.imagePath ?? '') as String;

    // Kelompokkan item per kategori
    final exclusiveCombos = _allFoodItems
        .where((f) => f.category == 'exclusive_combo')
        .toList();
    final combos = _allFoodItems.where((f) => f.category == 'combo').toList();
    final snacks = _allFoodItems.where((f) => f.category == 'snack').toList();
    final drinks = _allFoodItems.where((f) => f.category == 'drink').toList();

    // Recommended item (tampilkan jika ada item di cart ATAU default pertama)
    FoodItem? recommendedItem;
    if (_hasItemInCart) {
      // Tampilkan item pertama di cart sebagai recommended
      final firstCartId = _cart.keys.first;
      try {
        recommendedItem = _allFoodItems.firstWhere((f) => f.id == firstCartId);
      } catch (_) {}
    } else if (_recommendedId != null) {
      try {
        recommendedItem = _allFoodItems.firstWhere(
          (f) => f.id == _recommendedId,
        );
      } catch (_) {}
    }

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
        title: const Text(
          'Food & Beverages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timer Banner ──
                  _buildTimerBanner(),

                  // ── Info Film + Booking ──
                  _buildBookingInfo(title, imagePath),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // ── Recommended ──
                  if (recommendedItem != null) ...[
                    _buildSectionHeader('Recommended'),
                    _buildRecommendedCard(recommendedItem),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),
                  ],

                  // ── Exclusive Combo ──
                  if (exclusiveCombos.isNotEmpty) ...[
                    _buildSectionLabel('- EXCLUSIVE COMBO'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(exclusiveCombos),
                    const SizedBox(height: 20),
                  ],

                  // ── Combo ──
                  if (combos.isNotEmpty) ...[
                    _buildSectionLabel('COMBO'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(combos),
                    const SizedBox(height: 20),
                  ],

                  // ── Snack ──
                  if (snacks.isNotEmpty) ...[
                    _buildSectionLabel('SNACK'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(snacks),
                    const SizedBox(height: 20),
                  ],

                  // ── Drink ──
                  if (drinks.isNotEmpty) ...[
                    _buildSectionLabel('DRINK'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(drinks),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom Bar ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Timer Banner ──
  Widget _buildTimerBanner() {
    final isUrgent = _remainingSeconds < 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFFFCE4EC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Waiting for Payment  ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : const Color(0xFFE91E63),
            ),
            child: Text(_timerText),
          ),
        ],
      ),
    );
  }

  // ── Booking Info ──
  Widget _buildBookingInfo(String title, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    width: 80,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderPoster(),
                  )
                : _placeholderPoster(),
          ),
          const SizedBox(width: 14),
          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _infoRow(Icons.location_on_outlined, widget.cinemaName),
                const SizedBox(height: 6),
                _infoRow(
                  Icons.confirmation_number_outlined,
                  '${widget.screenType.split(' ').first}, CINEMA${widget.selectedSeats.isNotEmpty ? _getCinemaNumber() : ''}',
                ),
                const SizedBox(height: 6),
                _infoRow(
                  Icons.calendar_today_outlined,
                  '${_formatDate(widget.date)} - ${widget.time}',
                ),
                const SizedBox(height: 12),
                // Skip to payment button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Skip To Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCinemaNumber() {
    // Simulasi nomor studio
    final hash = widget.cinemaName.length + widget.time.hashCode.abs() % 10;
    return '0${(hash % 9) + 1}';
  }

  Widget _placeholderPoster() {
    return Container(
      width: 80,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.movie, color: Colors.grey, size: 32),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  // ── Section Header (Recommended) ──
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: () => _goToPayment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommended Card ──
  Widget _buildRecommendedCard(FoodItem item) {
    final qty = _cart[item.id] ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar
          _buildFoodImage(item, 70, 70),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Qty control
          Column(
            children: [
              _QtyControl(
                qty: qty,
                onAdd: () => _addToCart(item.id),
                onRemove: () => _removeFromCart(item.id),
              ),
              if (qty > 0) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showEditDialog(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Label ──
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Horizontal Grid (2 kolom) ──
  Widget _buildHorizontalGrid(List<FoodItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _buildFoodCard(item)).toList(),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    final qty = _cart[item.id] ?? 0;
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: _buildFoodImage(item, 170, 140),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                _QtyControl(
                  qty: qty,
                  onAdd: () => _addToCart(item.id),
                  onRemove: () => _removeFromCart(item.id),
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(FoodItem item, double w, double h) {
    if (item.imagePath.isNotEmpty) {
      return Image.asset(
        item.imagePath,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _foodPlaceholder(w, h),
      );
    }
    return _foodPlaceholder(w, h);
  }

  Widget _foodPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood_rounded,
            color: Colors.grey.shade400,
            size: h * 0.3,
          ),
          const SizedBox(height: 4),
          Text(
            'Foto\nsegera hadir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    final cartCount = _cart.values.fold(0, (a, b) => a + b);

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
          // Summary kursi
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.event_seat_rounded,
                  size: 15,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${widget.selectedSeats.join(', ')} — ${_formatPrice(_ticketTotal)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A237E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (cartCount > 0) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.fastfood_rounded,
                    size: 15,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$cartCount item F&B — ${_formatPrice(_totalFoodPrice)}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    _formatPrice(_grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    '${widget.selectedSeats.length} tiket${cartCount > 0 ? ' + $cartCount F&B' : ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              // Checkout button
              ElevatedButton(
                onPressed: _goToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  cartCount > 0 ? 'Checkout' : 'Lanjut Bayar',
                  style: const TextStyle(
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

  // ── Actions ──
  void _goToPayment() {
    _timer?.cancel();
    final foodOrder = _cart.entries.where((e) => e.value > 0).map((e) {
      final item = _allFoodItems.firstWhere((f) => f.id == e.key);
      return {'name': item.name, 'qty': e.value, 'price': item.price};
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSummaryScreen(
          movie: widget.movie,
          cinemaName: widget.cinemaName,
          screenType: widget.screenType,
          time: widget.time,
          date: widget.date,
          selectedSeats: widget.selectedSeats,
          ticketPrice: widget.ticketPrice,
          foodOrder: foodOrder,
        ),
      ),
    );
  }

  void _showEditDialog(FoodItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (ctx, setLocalState) {
            final qty = _cart[item.id] ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QtyControl(
                  qty: qty,
                  onAdd: () {
                    _addToCart(item.id);
                    setLocalState(() {});
                  },
                  onRemove: () {
                    _removeFromCart(item.id);
                    setLocalState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}

// ─── QTY CONTROL WIDGET 
class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool compact;

  const _QtyControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 30 : 34;
    final double fontSize = compact ? 14 : 16;

    if (qty == 0) {
      // Hanya tampilkan tombol +
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add, color: Colors.white, size: fontSize),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, color: Colors.white, size: fontSize),
          ),
        ),
        SizedBox(
          width: compact ? 28 : 32,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.white, size: fontSize),
          ),
        ),
      ],
    );
  }
}

// TAMBAHKAN DI PALING BAWAH FILE seat_selection_screen.dart
List<FoodItem> get globalFoodItems => _allFoodItems;
