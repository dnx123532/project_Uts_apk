// PLACEHOLDER PAGES
import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/widgets/app_image.dart';
import 'package:project_uts_apk/screens/bookings/booking_history_page.dart';
import 'package:project_uts_apk/screens/movie/movie_detail_screen.dart';
import 'package:project_uts_apk/screens/login/login_screen.dart';
import 'package:project_uts_apk/providers/movie_provider.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});
  @override
  Widget build(BuildContext context) => const BookingHistoryPage();
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final allMovies = context.watch<MovieProvider>().movies;

    // 2. Lakukan penyaringan (filter) dari data API tersebut
    final filteredMovies = allMovies
        .where((m) => m.title.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Column(
      children: [
        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: InputDecoration(
              hintText: 'Cari film...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // LIST MOVIE
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = filteredMovies[index];

              return GestureDetector(
                onTap: () {
                  if (authState.isLoggedIn) {
                    // Kalau sudah login, arahkan ke Detail Film
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  } else {
                    // Kalau belum login, lempar ke halaman Login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );

                    // Kasih pesan kecil biar user tau kenapa dilempar ke login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Login dulu yuk buat liat detail filmnya!",
                        ),
                        backgroundColor: Color(0xFF1A237E),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppImage(
                      path: movie.imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
