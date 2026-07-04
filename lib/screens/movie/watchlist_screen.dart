import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/providers/movie_provider.dart';
import 'package:project_uts_apk/screens/login/login_screen.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    // Reset badge saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      watchlistState.markAsSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Watchlist Saya',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: watchlistState,
        builder: (context, _) {
          // Belum login
          if (!authState.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 72, color: const Color(0xFF1A237E).withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('Kamu belum login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  const Text('Login untuk menyimpan film favorit kamu',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Masuk / Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          final titles = watchlistState.titles;

          // Watchlist kosong
          if (titles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 72, color: const Color(0xFF1A237E).withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('Watchlist masih kosong',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  const Text('Tekan ❤ di halaman detail film untuk menambahkan',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Cocokkan dengan data film dari provider (case-insensitive)
          final allMovies = context.watch<MovieProvider>().movies;
          final titlesLower = titles.map((t) => t.toLowerCase()).toSet();
          final watchlistMovies = allMovies
              .where((m) => titlesLower.contains(m.title.toLowerCase()))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: watchlistMovies.isEmpty ? titles.length : watchlistMovies.length,
            itemBuilder: (context, index) {
              // Kalau movie sudah di-load dari provider
              if (watchlistMovies.isNotEmpty) {
                final movie = watchlistMovies[index];
                return _WatchlistCard(
                  title: movie.title,
                  genre: movie.genre,
                  imagePath: movie.imagePath,
                  rating: movie.rating,
                  duration: movie.duration,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                  ),
                  onRemove: () => watchlistState.toggle(movie.title),
                );
              }
              // Fallback: movie belum load, tampilkan judul saja
              return _WatchlistCard(
                title: titles[index],
                genre: '',
                imagePath: '',
                rating: 0,
                duration: '',
                onTap: () {},
                onRemove: () => watchlistState.toggle(titles[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final String title;
  final String genre;
  final String imagePath;
  final double rating;
  final String duration;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WatchlistCard({
    required this.title,
    required this.genre,
    required this.imagePath,
    required this.rating,
    required this.duration,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: _buildPoster(),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (genre.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(genre, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                    if (rating > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(rating.toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          if (duration.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Text(duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Tombol hapus dari watchlist
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
              tooltip: 'Hapus dari watchlist',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    if (imagePath.isEmpty) {
      return Container(
        width: 80, height: 110,
        color: Colors.grey.shade200,
        child: const Icon(Icons.movie, color: Colors.grey),
      );
    }
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, width: 80, height: 110, fit: BoxFit.cover,
          errorBuilder: (ctx, e, stack) => Container(
              width: 80, height: 110, color: Colors.grey.shade200,
              child: const Icon(Icons.movie, color: Colors.grey)));
    }
    return Image.asset(imagePath, width: 80, height: 110, fit: BoxFit.cover,
        errorBuilder: (ctx, e, stack) => Container(
            width: 80, height: 110, color: Colors.grey.shade200,
            child: const Icon(Icons.movie, color: Colors.grey)));
  }
}
