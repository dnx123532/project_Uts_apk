// HOME CONTENT
import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/data/data_film.dart';
import 'package:flutter_application_for_us/screens/country/city_selection_screen.dart';
import 'package:flutter_application_for_us/screens/login/login_screen.dart';
import 'package:flutter_application_for_us/screens/notification/notification_screen.dart';
import 'package:flutter_application_for_us/screens/payments/payment_process_screen.dart';
import 'package:flutter_application_for_us/screens/profile/profile_screen.dart';
import 'package:flutter_application_for_us/widgets/movie_card.dart';
import 'package:flutter_application_for_us/widgets/section_header.dart';

import '../movie/movie_detail_screen.dart';
import '../../widgets/upcoming_card.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback onSeeAllTap;

  const HomeContent({super.key, required this.onSeeAllTap});

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
                        IconButton(
                          icon: const Icon(Icons.favorite_border_rounded),
                          onPressed: () {},
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
                                  } else {
                                    // Logic buat beli tiket banner (misal ke halaman film tersebut)
                                  }
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
              SectionHeader(title: 'Sedang Tayang', onSeeAll: onSeeAllTap),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: 0.35,
                    initialPage: 1,
                  ),
                  itemCount: nowShowingMovies.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // 1. Cek dulu status loginnya
                        if (authState.isLoggedIn) {
                          // 2. Kalau sudah login, arahkan ke Detail Film
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(
                                movie: nowShowingMovies[index],
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

                          // Opsional: Kasih pesan biar user gak bingung
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Login dulu yuk buat liat detail filmnya!",
                              ),
                            ),
                          );
                        }
                      },
                      child: AnimatedMovieCard(movie: nowShowingMovies[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Segera Hadir', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: upcomingMovies.length,
                  itemBuilder: (context, index) =>
                      UpcomingCard(movie: upcomingMovies[index]),
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
