import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/providers/cinema_provider.dart';
import 'package:provider/provider.dart';
import 'package:project_uts_apk/screens/country/city_selection_screen.dart';
import 'package:project_uts_apk/widgets/cinema_card_with_nav.dart';
import 'package:video_player/video_player.dart';
import '../../models/cinema_model.dart';
import '../../widgets/info_row.dart';
import '../../widgets/cast_chip.dart';

// ─── DATA BIOSKOP MEDAN ───────────────────────────────────────────────────────
// Edit jadwal di sini sesuai kebutuhan

// Fungsi generate tanggal mulai hari ini (7 hari ke depan)
List<DateTime> getUpcomingDates() {
  final now = DateTime.now();
  return List.generate(7, (i) => now.add(Duration(days: i)));
}

String dayName(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

// ─── MOVIE DETAIL SCREEN ──────────────────────────────────────────────────────
class MovieDetailScreen extends StatefulWidget {
  // Terima MovieModel dari tixio_app.dart
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

  List<CinemaSchedule> filteredCinemas(BuildContext context) {
    final cinemasInCity = context.watch<CinemaProvider>().getByCity(locationState.selectedCity);
    if (_selectedScreenType == 'All') return cinemasInCity;
    return cinemasInCity.where((c) => c.screenType.contains(_selectedScreenType)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    // Ambil data langsung dari objek movie dengan super bersih!
    final String title = movie.title;
    final String genre = movie.genre;
    final String duration = movie.duration;
    final double rating = movie.rating;
    final String imagePath = movie.imagePath;
    final String synopsis = movie.synopsis;
    final String year = movie.year;
    final String ageRating = movie.ageRating;
    final String? trailerPath = movie.trailerPath;

    // Memecah teks cast dari API (String) menjadi daftar List<String>
    // agar perulangan di UI lu tetap berjalan lancar.
    final List<String> cast = movie.cast.isEmpty ? [] : movie.cast.split(', ');

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
                errorBuilder: (_, _, _) => Container(
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
            // Watchlist button
            Positioned(
              top: 40,
              right: 12,
              child: AnimatedBuilder(
                animation: watchlistState,
                builder: (context, _) {
                  final inList = watchlistState.isInWatchlist(title);
                  return IconButton(
                    icon: Icon(
                      inList ? Icons.favorite_rounded : Icons.favorite_border,
                      color: inList ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      if (!authState.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login dulu untuk menyimpan watchlist')),
                        );
                        return;
                      }
                      watchlistState.toggle(title);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(inList ? 'Dihapus dari watchlist' : 'Ditambahkan ke watchlist'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: inList ? Colors.grey : const Color(0xFF1A237E),
                        ),
                      );
                    },
                  );
                },
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
                    errorBuilder: (_, _, _) => Container(
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
          if (context.watch<CinemaProvider>().isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
            )
          else
            ...filteredCinemas(context).map(
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
          InfoRow(label: 'Genre', value: genre),
          InfoRow(label: 'Durasi', value: duration),
          InfoRow(label: 'Tahun', value: year),
          InfoRow(label: 'Rating', value: '$rating / 10'),
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
            children: cast.map((name) => CastChip(name: name)).toList(),
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
}

// ── HELPER: data sinopsis & cast per film ─────────────────────────────────
// ✏️ Edit sinopsis & cast sesuai film kamu

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
