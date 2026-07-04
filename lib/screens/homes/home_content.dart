// HOME CONTENT
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/screens/country/city_selection_screen.dart';
import 'package:project_uts_apk/screens/login/login_screen.dart';
import 'package:project_uts_apk/screens/notification/notification_screen.dart';
import 'package:project_uts_apk/screens/profile/profile_screen.dart';
import 'package:project_uts_apk/screens/movie/watchlist_screen.dart';
import 'package:project_uts_apk/widgets/movie_card.dart';
import 'package:project_uts_apk/widgets/section_header.dart';
import 'package:project_uts_apk/providers/movie_provider.dart';
import 'package:project_uts_apk/services/seed_service.dart';
import 'package:provider/provider.dart';
import '../movie/movie_detail_screen.dart';
import '../../widgets/upcoming_card.dart';

class HomeContent extends StatefulWidget {
  final VoidCallback onSeeAllTap;
  const HomeContent({super.key, required this.onSeeAllTap});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final PageController _sponsorCtrl;
  Timer? _sponsorTimer;
  int _sponsorPage = 0;

  static const _sponsors = [
    'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/sponsor1.png',
    'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/sponsor2.png',
  ];

  @override
  void initState() {
    super.initState();
    _sponsorCtrl = PageController();
    _sponsorTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _sponsorPage = (_sponsorPage + 1) % _sponsors.length;
      if (_sponsorCtrl.hasClients) {
        _sponsorCtrl.animateToPage(
          _sponsorPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sponsorTimer?.cancel();
    _sponsorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        final name = authState.username ?? 'Guest';
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CitySelectionScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          // <-- Row yang abang temuin tadi sekarang di sini, tanpa 'const'
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            AnimatedBuilder(
                              animation: locationState,
                              builder: (context, _) => Text(
                                locationState
                                    .selectedCity, // <-- Sekarang dinamis ambil dari state global
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: watchlistState,
                          builder: (context, _) {
                            final count = watchlistState.unreadCount;
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border_rounded),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                                  ),
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: 8, top: 8,
                                    child: Container(
                                      width: 16, height: 16,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text('$count',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: bookingState,
                          builder: (context, _) {
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                  ),
                                  onPressed: () {
                                    // Hilangkan titik merah saat icon ditekan
                                    if (bookingState.unreadCount > 0) {
                                      bookingState.clearNotifications();
                                    }

                                    // Pindah ke halaman Notifikasi
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationScreen(),
                                      ),
                                    );
                                  },
                                ),
                                // Titik merah
                                if (bookingState.unreadCount > 0)
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            if (authState.isLoggedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF1A237E),
                            child: authState.isLoggedIn
                                ? Text(
                                    authState.username![0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: 'Halo, ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: name),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Mau nonton film apa hari ini?',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3E1F00), Color(0xFF1A0A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: GrainPainter()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'SAMARA WEAVING - KATHRYN NEWTON',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'READY OR NOT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'HERE I COME',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Cari ElevatedButton di dalam banner HomeContent
                              ElevatedButton(
                                onPressed: () {
                                  if (!authState.isLoggedIn) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                    return;
                                  }
                                  widget.onSeeAllTap(); // pindah ke tab Movie
                                },
                                child: const Text('Pesan Tiket'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Sedang Tayang', onSeeAll: widget.onSeeAllTap),
              const SizedBox(height: 12),
              Consumer<MovieProvider>(
                builder: (context, movieProvider, child) {
                  // 1. Tampilan saat API lagi ditarik (Loading)
                  if (movieProvider.isLoading) {
                    return const SizedBox(
                      height: 275,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    );
                  }

                  // 2. Tampilan kalau offline dan database HP kosong
                  if (movieProvider.errorMessage.isNotEmpty &&
                      movieProvider.movies.isEmpty) {
                    return SizedBox(
                      height: 275,
                      child: Center(
                        child: Text(
                          movieProvider.errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // 3. Tampilan Sukses (Data berhasil ditarik)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indikator kecil kalau lagi pakai mode offline
                      if (movieProvider.isOffline)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 14,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                ' Mode Offline',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(
                        height: 275,
                        child: PageView.builder(
                          controller: PageController(
                            viewportFraction: 0.35,
                            initialPage: 1,
                          ),
                          // GANTI 1: Pakai length dari API
                          itemCount: movieProvider.movies.length,
                          itemBuilder: (context, index) {
                            // GANTI 2: Ambil data spesifik dari index API
                            final movie = movieProvider.movies[index];

                            return GestureDetector(
                              onTap: () {
                                // 1. Cek dulu status loginnya
                                if (authState.isLoggedIn) {
                                  // 2. Kalau sudah login, arahkan ke Detail Film
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(
                                        movie:
                                            movie, // GANTI 3: Lempar data API ke Detail
                                      ),
                                    ),
                                  );
                                } else {
                                  // 3. Kalau belum login, paksa ke halaman Login
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );

                                  // Kasih pesan biar user gak bingung
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Login dulu yuk buat liat detail filmnya!",
                                      ),
                                    ),
                                  );
                                }
                              },
                              // GANTI 4: Masukkan data API ke widget card lu
                              child: AnimatedMovieCard(movie: movie),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Segera Hadir', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: SeedService.upcomingMovies.length,
                  itemBuilder: (context, index) =>
                      UpcomingCard(movie: SeedService.upcomingMovies[index]),
                ),
              ),
              const SizedBox(height: 24),
              // ── Banner Sponsor ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Promo & Sponsor',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: PageView.builder(
                        controller: _sponsorCtrl,
                        itemCount: _sponsors.length,
                        onPageChanged: (i) => _sponsorPage = i,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _sponsors[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (ctx, e, s) => Container(
                                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                                child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 40)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dot indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_sponsors.length, (i) {
                        return AnimatedBuilder(
                          animation: _sponsorCtrl,
                          builder: (context, _) {
                            final active = _sponsorCtrl.hasClients
                                ? (_sponsorCtrl.page?.round() ?? 0) == i
                                : i == 0;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 20 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: active ? const Color(0xFF1A237E) : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
