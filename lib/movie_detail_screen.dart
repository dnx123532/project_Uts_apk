import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './seat_selection_screen.dart';
import './main.dart';
// Import dari file utama — pastikan nama file sesuai

// ─── DATA BIOSKOP MEDAN ───────────────────────────────────────────────────────
// Edit jadwal di sini sesuai kebutuhan

class CinemaSchedule {
  final String cinemaName;
  final String screenType;
  final int price;
  final List<String> times;

  const CinemaSchedule({
    required this.cinemaName,
    required this.screenType,
    required this.price,
    required this.times,
  });
}

// Fungsi generate tanggal mulai hari ini (7 hari ke depan)
List<DateTime> getUpcomingDates() {
  final now = DateTime.now();
  return List.generate(7, (i) => now.add(Duration(days: i)));
}

String dayName(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

// Data bioskop Medan - edit jadwal & harga sesuai kebutuhan
// DATA BIOSKOP 10 KOTA
final Map<String, List<CinemaSchedule>> cityCinemas = {
  'Jakarta': [
    const CinemaSchedule(
      cinemaName: 'Grand Indonesia',
      screenType: 'REGULAR 2D',
      price: 60000,
      times: ['12:00', '14:30', '17:00', '19:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Senayan City',
      screenType: 'IMAX 2D',
      price: 85000,
      times: ['13:00', '16:00', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Kelapa Gading',
      screenType: 'VIP 2D',
      price: 120000,
      times: ['14:00', '18:00', '20:30'],
    ),
  ],
  'Bandung': [
    const CinemaSchedule(
      cinemaName: 'Ciwalk',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:30', '15:00', '18:00', '20:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Paris Van Java',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['13:15', '16:15', '19:15'],
    ),
    const CinemaSchedule(
      cinemaName: 'Trans Studio Mall',
      screenType: 'MACRO XE',
      price: 65000,
      times: ['14:00', '17:30'],
    ),
  ],
  'Bali': [
    const CinemaSchedule(
      cinemaName: 'Beachwalk',
      screenType: 'REGULAR 2D',
      price: 60000,
      times: ['13:00', '16:00', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Level 21',
      screenType: 'REGULAR 2D',
      price: 55000,
      times: ['12:30', '15:30', '18:30'],
    ),
  ],
  'Balikpapan': [
    const CinemaSchedule(
      cinemaName: 'Pentacity',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['12:00', '14:30', '17:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'E-Walk',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Batam': [
    const CinemaSchedule(
      cinemaName: 'Mega Mall',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['12:15', '15:15', '18:15'],
    ),
    const CinemaSchedule(
      cinemaName: 'Grand Batam Mall',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:30', '16:30', '19:30'],
    ),
  ],
  'Bekasi': [
    const CinemaSchedule(
      cinemaName: 'Summarecon Mall',
      screenType: 'IMAX 2D',
      price: 65000,
      times: ['12:00', '15:00', '18:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Mega Bekasi',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:00', '15:30', '18:30'],
    ),
  ],
  'Bogor': [
    const CinemaSchedule(
      cinemaName: 'Botani Square',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:45', '15:45', '18:45'],
    ),
    const CinemaSchedule(
      cinemaName: 'Cibinong City',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:15', '16:15', '19:15'],
    ),
  ],
  'Makassar': [
    const CinemaSchedule(
      cinemaName: 'Trans Studio Mall',
      screenType: 'REGULAR 2D',
      price: 50000,
      times: ['12:00', '14:30', '17:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Panakkukang',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Palembang': [
    const CinemaSchedule(
      cinemaName: 'Palembang Icon',
      screenType: 'REGULAR 2D',
      price: 45000,
      times: ['12:30', '15:00', '17:30'],
    ),
    const CinemaSchedule(
      cinemaName: 'Palembang Square',
      screenType: 'REGULAR 2D',
      price: 40000,
      times: ['13:00', '15:30', '18:00'],
    ),
  ],
  'Medan': [
    const CinemaSchedule(
      cinemaName: 'Plaza Medan Fair',
      screenType: 'REGULAR 2D',
      price: 44000,
      times: ['12:00', '13:25', '14:25', '16:50', '19:15', '21:40'],
    ),
    const CinemaSchedule(
      cinemaName: 'Lippo Plaza Medan',
      screenType: 'REGULAR 2D',
      price: 37000,
      times: ['12:00', '14:20', '16:40', '19:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Sun Plaza',
      screenType: 'IMAX 2D',
      price: 65000,
      times: ['13:00', '16:00', '20:00'],
    ),
    const CinemaSchedule(
      cinemaName: 'Hermes Place',
      screenType: 'REGULAR 2D',
      price: 35000,
      times: ['13:30', '16:00', '18:30'],
    ),
  ],
};

// MOVIE DETAIL SCREEN
class MovieDetailScreen extends StatefulWidget {
  // Terima MovieModel dari main.dart
  final dynamic movie; // pakai dynamic agar fleksibel

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDateIndex = 0;
  String _selectedScreenType = 'All';
  String _selectedDimension = 'All';
  final List<DateTime> _dates = getUpcomingDates();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CinemaSchedule> get filteredCinemas {
    // Tarik data bioskop sesuai kota yang dipilih. Kalau error/kosong, fallback ke Medan
    final cinemasInCity =
        cityCinemas[locationState.selectedCity] ?? cityCinemas['Medan']!;

    if (_selectedScreenType == 'All') return cinemasInCity;
    return cinemasInCity
        .where((c) => c.screenType.contains(_selectedScreenType))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    // Ambil field dari movie, dengan fallback aman
    final String title = movie.title ?? '';
    final String genre = movie.genre ?? '';
    final String duration = movie.duration ?? '';
    final double rating = movie.rating ?? 0.0;
    final String imagePath = movie.imagePath ?? '';
    final String synopsis = _getSynopsis(title);
    final List<String> cast = _getCast(title);
    final String year = _getYear(title);
    final String ageRating = _getAgeRating(title);
    final String? trailerPath = _getTrailerPath(title);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _buildHeader(
              context,
              imagePath: imagePath,
              title: title,
              genre: genre,
              duration: duration,
              rating: rating,
              year: year,
              ageRating: ageRating,
              trailerPath: trailerPath,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1A237E),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                indicatorColor: const Color(0xFF1A237E),
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'About Movie'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: SCHEDULE ──
            _buildScheduleTab(),
            // ── TAB 2: ABOUT MOVIE ──
            _buildAboutTab(
              synopsis: synopsis,
              cast: cast,
              genre: genre,
              duration: duration,
              year: year,
              rating: rating,
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER (Backdrop + Info) ──────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String genre,
    required String duration,
    required double rating,
    required String year,
    required String ageRating,
    String? trailerPath,
  }) {
    return Column(
      children: [
        // Backdrop image dengan tombol play trailer
        Stack(
          children: [
            // Backdrop
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A237E).withOpacity(0.3),
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54, size: 60),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: 40,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Wishlist button
            Positioned(
              top: 40,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ),
            // Play trailer button (tengah)
            if (trailerPath != null)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () => _openTrailer(context, trailerPath),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF1A237E),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Info card (muncul di atas backdrop — desain overlap)
        Transform.translate(
          offset: const Offset(0, -24),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster kecil
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 120,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${genre.split(',').first.trim().toUpperCase()} • $duration',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            year,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const _Divider(),
                          Text(
                            ageRating,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const _Divider(),
                          const Text(
                            'IDN',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '/10',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }

  // ── SCHEDULE TAB ─────────────────────────────────────────────────────────
  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search kota
          // Search kota (Diubah jadi dinamis)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
              ).then((_) => setState(() {})); // Reload bioskop pas balik
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                // <-- hapus 'const' di sini karena isinya dinamis
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Color(0xFF1A237E)),
                  const SizedBox(width: 8),
                  Text(
                    locationState
                        .selectedCity, // <-- Namanya otomatis ngikutin state global
                    style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pilih tanggal
          SizedBox(
            height: 68,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (context, i) {
                final date = _dates[i];
                final selected = i == _selectedDateIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: 58,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1A237E)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1A237E)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          dayName(date),
                          style: TextStyle(
                            color: selected ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Screen Type filter
          const Text(
            'Screen Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['All', 'REGULAR', 'IMAX', '4DX'].map((type) {
              final selected = _selectedScreenType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedScreenType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1A237E)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Dimensi filter (All / 2D)
          Row(
            children: ['All', '2D'].map((dim) {
              return GestureDetector(
                onTap: () => setState(() => _selectedDimension = dim),
                child: Row(
                  children: [
                    Radio<String>(
                      value: dim,
                      groupValue: _selectedDimension,
                      activeColor: const Color(0xFF1A237E),
                      onChanged: (v) => setState(() => _selectedDimension = v!),
                    ),
                    Text(dim, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Daftar bioskop
          ...filteredCinemas.map(
            (cinema) => CinemaCardWithNav(
              cinema: cinema,
              movie: widget.movie,
              selectedDate: _dates[_selectedDateIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ── ABOUT MOVIE TAB ───────────────────────────────────────────────────────
  Widget _buildAboutTab({
    required String synopsis,
    required List<String> cast,
    required String genre,
    required String duration,
    required String year,
    required double rating,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sinopsis
          const Text(
            'Sinopsis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            synopsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Info Film
          const Text(
            'Info Film',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Genre', value: genre),
          _InfoRow(label: 'Durasi', value: duration),
          _InfoRow(label: 'Tahun', value: year),
          _InfoRow(label: 'Rating', value: '$rating / 10'),
          const SizedBox(height: 20),

          // Pemain
          const Text(
            'Pemain',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cast.map((name) => _CastChip(name: name)).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── BUKA TRAILER ─────────────────────────────────────────────────────────
  void _openTrailer(BuildContext context, String trailerPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TrailerScreen(trailerPath: trailerPath),
      ),
    );
  }

  // ── HELPER: data sinopsis & cast per film ─────────────────────────────────
  // ✏️ Edit sinopsis & cast sesuai film kamu
  String _getSynopsis(String title) {
    final t = title.toLowerCase();
    if (t.contains('avengers') && t.contains('endgame')) {
      return 'Setelah Thanos menggunakan Infinity Gauntlet untuk membinasakan setengah dari semua kehidupan, para Avengers yang tersisa harus menemukan cara untuk mengalahkannya sekali lagi.';
    } else if (t.contains('chainsaw')) {
      return 'Denji adalah seorang pemuda miskin yang terjerat hutang ayahnya kepada Yakuza. Dengan bantuan anjing iblis Pochita, ia menjadi Chainsaw Man demi bertahan hidup.';
    } else if (t.contains('dark knight')) {
      return 'Batman menghadapi musuh terbesar dalam hidupnya — Joker, seorang kriminal jenius yang bertujuan menebarkan kekacauan dan menguji batas moral Gotham City.';
    } else if (t.contains('look back')) {
      return 'Fujino dan Kyomoto, dua anak yang sama-sama mencintai manga, menjalani perjalanan hidup yang saling bersilangan meski dengan jalan yang berbeda.';
    } else if (t.contains('jujutsu')) {
      return 'Yuta Okkotsu dikutuk oleh arwah gadis yang ia cintai. Di bawah bimbingan Satoru Gojo, ia bergabung dengan sekolah jujutsu untuk menguasai kekuatannya.';
    } else if (t.contains('conjuring')) {
      return 'Pasangan paranormal Ed dan Lorraine Warren menyelidiki serangkaian kejadian misterius di sebuah rumah pertanian di Rhode Island yang dihuni oleh keluarga Perron.';
    } else if (t.contains('toy story')) {
      return 'Woody bertemu boneka baru bernama Forky yang tidak menganggap dirinya mainan. Petualangan seru pun dimulai ketika Forky melarikan diri dari pemilik barunya, Bonnie.';
    } else if (t.contains('infinity war')) {
      return 'Thanos memulai misinya untuk mengumpulkan semua Infinity Stone. Para Avengers dan sekutu-sekutunya bersatu untuk mencegah kehancuran alam semesta.';
    } else if (t.contains('now you see me')) {
      return 'Empat pesulap melakukan pertunjukan yang menguras bank sungguhan dan menyebarkan uangnya ke penonton. Agen FBI pun mengejar mereka.';
    } else if (t.contains('merah putih') || t.contains('one for all')) {
      return 'Kisah perjuangan para prajurit Indonesia dalam mempertahankan kemerdekaan dengan semangat persatuan dan keberanian yang tak pernah padam.';
    }
    return 'Nikmati pengalaman sinematik yang luar biasa. Film ini menghadirkan cerita yang memukau dengan visual yang menakjubkan dan akting memukau dari para pemain.';
  }

  List<String> _getCast(String title) {
    final t = title.toLowerCase();
    if (t.contains('avengers') && t.contains('endgame')) {
      return [
        'Robert Downey Jr.',
        'Chris Evans',
        'Scarlett Johansson',
        'Mark Ruffalo',
        'Chris Hemsworth',
        'Josh Brolin',
      ];
    } else if (t.contains('chainsaw')) {
      return [
        'Kikunosuke Toya',
        'Tomori Kusunoki',
        'Mariya Ise',
        'Shiori Izawa',
      ];
    } else if (t.contains('dark knight')) {
      return [
        'Christian Bale',
        'Heath Ledger',
        'Aaron Eckhart',
        'Maggie Gyllenhaal',
        'Gary Oldman',
      ];
    } else if (t.contains('look back')) {
      return ['Mizuki Yoshida', 'Genya Aoki'];
    } else if (t.contains('jujutsu')) {
      return [
        'Megumi Ogata',
        'Kana Hanazawa',
        'Takahiro Sakurai',
        'Yuichi Nakamura',
      ];
    } else if (t.contains('conjuring')) {
      return [
        'Patrick Wilson',
        'Vera Farmiga',
        'Ron Livingston',
        'Lili Taylor',
      ];
    } else if (t.contains('toy story')) {
      return [
        'Tom Hanks',
        'Tim Allen',
        'Annie Potts',
        'Tony Hale',
        'Keegan-Michael Key',
      ];
    } else if (t.contains('infinity war')) {
      return [
        'Robert Downey Jr.',
        'Chris Hemsworth',
        'Mark Ruffalo',
        'Chris Evans',
        'Benedict Cumberbatch',
      ];
    } else if (t.contains('now you see me')) {
      return [
        'Jesse Eisenberg',
        'Mark Ruffalo',
        'Woody Harrelson',
        'Isla Fisher',
        'Dave Franco',
      ];
    }
    return ['Pemain 1', 'Pemain 2', 'Pemain 3'];
  }

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

  // ✏️ Ganti path trailer sesuai assets kamu
  String? _getTrailerPath(String title) {
    final t = title.toLowerCase();
    // Contoh: return 'assets/trailers/endgame.mp4';
    // Kembalikan null jika film tidak punya trailer
    if (t.contains('endgame')) return 'assets/videos/avengerendgame.mp4';
    if (t.contains('chainsaw')) return 'assets/videos/chainsawman.mp4';
    if (t.contains('dark knight')) return 'assets/videos/thedarkknight.mp4';
    if (t.contains('look back')) return 'assets/videos/lookback.mp4';
    if (t.contains('jujutsu')) return 'assets/videos/jujutsukaisen.mp4';
    if (t.contains('conjuring')) return 'assets/videos/theconjuring.mp4';
    if (t.contains('toy story')) return 'assets/videos/toystory4.mp4';
    if (t.contains('infinity')) return 'assets/videos/infinitywar.mp4';
    if (t.contains('now you see')) return 'assets/videos/nowyouseeme.mp4';
    if (t.contains('merah') || t.contains('one for all'))
      return 'assets/videos/oneforall.mp4';
    return null;
  }
}

// ─── CINEMA CARD ──────────────────────────────────────────────────────────────
class _CinemaCard extends StatelessWidget {
  final CinemaSchedule cinema;
  const _CinemaCard({required this.cinema});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cinema.cinemaName,
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
                    cinema.screenType,
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
                    'Rp ${_formatPrice(cinema.price)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cinema.times
                    .map((time) => _TimeChip(time: time))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

// ─── TIME CHIP ────────────────────────────────────────────────────────────────
class _TimeChip extends StatefulWidget {
  final String time;
  const _TimeChip({required this.time});

  @override
  State<_TimeChip> createState() => _TimeChipState();
}

class _TimeChipState extends State<_TimeChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _selected ? const Color(0xFF1A237E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selected ? const Color(0xFF1A237E) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          widget.time,
          style: TextStyle(
            color: _selected ? Colors.white : Colors.black87,
            fontWeight: _selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── CAST CHIP ────────────────────────────────────────────────────────────────
class _CastChip extends StatelessWidget {
  final String name;
  const _CastChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 14, color: Color(0xFF1A237E)),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INFO ROW ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DIVIDER ─────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 14,
      color: Colors.grey.shade300,
    );
  }
}

// ─── TAB BAR DELEGATE ─────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_) => false;
}

// ─── TRAILER SCREEN ───────────────────────────────────────────────────────────
class _TrailerScreen extends StatefulWidget {
  final String trailerPath;
  const _TrailerScreen({required this.trailerPath});

  @override
  State<_TrailerScreen> createState() => _TrailerScreenState();
}

// Ganti SELURUH class _TrailerScreenState dengan ini

class _TrailerScreenState extends State<_TrailerScreen> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;
  double? _dragValue; // null = tidak sedang drag

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.asset(widget.trailerPath);
      await _controller.initialize();
      if (!mounted) return;
      _controller.setLooping(false);
      _controller.setVolume(1.0);
      _controller.addListener(() {
        if (mounted && _dragValue == null) setState(() {});
      });
      setState(() => _ready = true);
      _controller.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Trailer'),
        ),
        body: const Center(
          child: Text(
            'Trailer tidak tersedia',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    if (!_ready) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Trailer'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final totalSec = _controller.value.duration.inSeconds.toDouble();
    final currentSec =
        _dragValue ?? _controller.value.position.inSeconds.toDouble();
    final safeMax = totalSec <= 0 ? 1.0 : totalSec;
    final safeVal = currentSec.clamp(0.0, safeMax);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // ── Video ──
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // ── Play/pause icon tengah ──
          if (!_controller.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _controller.play()),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),

          // ── Progress bar bawah ──
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(Duration(seconds: safeVal.toInt())),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _fmt(_controller.value.duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: safeVal,
                    min: 0,
                    max: safeMax,
                    activeColor: const Color(0xFF1A237E),
                    inactiveColor: Colors.white30,

                    // Mulai drag → pause & simpan posisi drag
                    onChangeStart: (_) {
                      _controller.pause();
                    },

                    // Geser → HANYA update _dragValue, JANGAN seekTo di sini
                    onChanged: (val) {
                      setState(() => _dragValue = val);
                    },

                    // Lepas → baru seekTo sekali lalu play
                    onChangeEnd: (val) async {
                      _dragValue = null;
                      await _controller.seekTo(Duration(seconds: val.toInt()));
                      await _controller.play();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
