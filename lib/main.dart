import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import './movie_detail_screen.dart';
import './payment_screen.dart';
import './seat_selection_screen.dart';

void main() {
  runApp(const TixioApp());
}

class TixioApp extends StatelessWidget {
  const TixioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tixio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// AUTH STATE
class AuthState extends ChangeNotifier {
  String? _username;
  String? _email;
  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _username != null;

  void login(String username, String email) {
    _username = username;
    _email = email;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _email = null;
    notifyListeners();
  }
}

final AuthState authState = AuthState();

class LocationState extends ChangeNotifier {
  String _selectedCity = 'Medan'; // Default awal
  String get selectedCity => _selectedCity;

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
}

final LocationState locationState = LocationState();

// DATA FILM
class MovieModel {
  final String title;
  final String genre;
  final String imagePath;
  final String duration;
  final double rating;
  final String? trailerPath; // ← tambah ini
  final String synopsis;
  const MovieModel({
    required this.title,
    required this.genre,
    required this.imagePath,
    this.duration = '120 min',
    this.rating = 8.0,
    this.trailerPath, // ← tambah ini
    this.synopsis = '',
  });
}

// EDIT FILM NOW SHOWING DI SINI
final List<MovieModel> nowShowingMovies = [
  MovieModel(
    title: 'Avengers: Endgame',
    genre: 'Action, Adventure, Sci-Fi',
    imagePath: 'assets/images/avengerendgame.webp',
    duration: '181 min',
    rating: 8.4,
  ),
  MovieModel(
    title: 'chainsaw man',
    genre: 'Action, Anime, Supernatural',
    imagePath: 'assets/images/chainsawman.jpeg',
    duration: '97 min',
    rating: 8.5,
  ),
  MovieModel(
    title: 'the dark knight',
    genre: 'Action, Crime, Drama',
    imagePath: 'assets/images/thedarkknight.jpeg',
    duration: '152 min',
    rating: 9.0,
  ),
  MovieModel(
    title: 'Look back',
    genre: 'Drama, Slice of Life, Anime',
    imagePath: 'assets/images/lookback.jpeg',
    duration: '58 min',
    rating: 8.3,
  ),
  MovieModel(
    title: 'merah putih: one for all',
    genre: 'Action, War, Drama',
    imagePath: 'assets/images/oneforall.jpeg',
    duration: '110 min',
    rating: 7.2,
  ),
  MovieModel(
    title: 'jujutsu kaisen 0',
    genre: 'Action, Fantasy, Anime',
    imagePath: 'assets/images/jujutsukaisen.jpeg',
    duration: '105 min',
    rating: 7.8,
  ),
  MovieModel(
    title: 'now you see me',
    genre: 'Crime, Thriller, Mystery',
    imagePath: 'assets/images/nowyouseeme.jpeg',
    duration: '115 min',
    rating: 7.3,
  ),
  MovieModel(
    title: 'The Conjuring',
    genre: 'Horror, Mystery, Thrille',
    imagePath: 'assets/images/theconjuring.webp',
    duration: '112 min',
    rating: 7.5,
  ),
  MovieModel(
    title: 'toy story 4',
    genre: 'Animation, Adventure, Comedy',
    imagePath: 'assets/images/toystory4.jpeg',
    duration: '100 min',
    rating: 7.7,
  ),
  MovieModel(
    title: 'avengers: infinity war',
    genre: 'Action, Adventure, Sci-Fi',
    imagePath: 'assets/images/avengersinfinitywar.jpeg',
    duration: '149 min',
    rating: 8.4,
  ),
];

// EDIT FILM UPCOMING DI SINI
final List<MovieModel> upcomingMovies = [
  MovieModel(
    title: 'Upcoming 1',
    genre: 'Genre',
    imagePath: 'assets/images/upcoming1.jpg',
    duration: 'Coming Soon',
    rating: 0,
  ),
  MovieModel(
    title: 'Upcoming 2',
    genre: 'Genre',
    imagePath: 'assets/images/upcoming2.jpg',
    duration: 'Coming Soon',
    rating: 0,
  ),
];

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // GANTI nama file jika berbeda
      _controller = VideoPlayerController.asset(
        'assets/videos/splash_screen.mp4',
      );
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _videoReady = true);
      _controller.setLooping(false);
      _controller.setVolume(1.0); // ganti 0.0 jika mau tanpa suara
      _controller.play();
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration &&
            _controller.value.duration > Duration.zero) {
          _goToHome();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _videoFailed = true);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _goToHome();
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoFailed) return const _FallbackSplash();
    if (!_videoReady) return const _FallbackSplash(showLoading: true);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}

// FALLBACK SPLASH (jika video gagal atau masih loading)
class _FallbackSplash extends StatelessWidget {
  final bool showLoading;
  const _FallbackSplash({this.showLoading = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tixio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tiket bioskop mudah & cepat',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (showLoading) ...[
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(
        onSeeAllTap: () {
          setState(() => _currentIndex = 2);
        },
      ),
      const BookingPage(),
      const MoviePage(),
      const CinemaPage(),
      const FnBPage(),
    ];

    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(child: pages[_currentIndex]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            // Cari di dalam class _HomeScreenState bagian onTap:
            // Cari di dalam class _HomeScreenState bagian onTap:
            onTap: (i) {
              // Wajib login untuk tab Booking(1), Cinema(3), dan F&B(4)
              if ((i == 1 || i == 3 || i == 4) && !authState.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login dulu yuk buat akses fitur ini!"),
                    backgroundColor: Color(0xFF1A237E),
                  ),
                );
              } else {
                setState(() => _currentIndex = i);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1A237E),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                label: 'My Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.movie_filter_outlined),
                label: 'Movie',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.theaters_outlined),
                label: 'Cinema',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_dining_outlined),
                label: 'F&B',
              ),
            ],
          ),
        );
      },
    );
  }
}

// HOME CONTENT
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
                          child: CustomPaint(painter: _GrainPainter()),
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
              _SectionHeader(title: 'Sedang Tayang', onSeeAll: onSeeAllTap),
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
                      child: _AnimatedMovieCard(movie: nowShowingMovies[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Segera Hadir', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: upcomingMovies.length,
                  itemBuilder: (context, index) =>
                      _UpcomingCard(movie: upcomingMovies[index]),
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

// MOVIE CARD
class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              movie.imagePath,
              width: 140,
              height: 165,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 140,
                height: 165,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF1A237E).withOpacity(0.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambah\nPoster',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        movie.imagePath.split('/').last,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              movie.genre,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                movie.rating.toString(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedMovieCard extends StatelessWidget {
  final MovieModel movie;

  const _AnimatedMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _MovieCard(movie: movie),
      ),
    );
  }
}

// UPCOMING CARD
class _UpcomingCard extends StatelessWidget {
  final MovieModel movie;
  const _UpcomingCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              movie.imagePath,
              width: 180,
              height: 190,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 180,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah Poster',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.duration,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
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
}

// SECTION HEADER
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

// GRAIN PAINTER
class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    for (int i = 0; i < 200; i++) {
      canvas.drawCircle(
        Offset((i * 37.3) % size.width, (i * 53.7) % size.height),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegister = false;
  String? _error;

  void _submit() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty || (_isRegister && name.isEmpty)) {
      setState(() => _error = 'Semua field harus diisi!');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    final displayName = _isRegister ? name : email.split('@').first;
    authState.login(displayName, email);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tixio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'Tiket bioskop mudah & cepat',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRegister
                          ? 'Buat Akun Baru'
                          : 'Selamat Datang Kembali!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isRegister
                          ? 'Daftar sekarang dan nikmati film favoritmu'
                          : 'Masuk untuk melanjutkan',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (_isRegister) ...[
                      _InputField(
                        controller: _nameCtrl,
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _InputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isRegister ? 'Daftar Sekarang' : 'Masuk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegister
                              ? 'Sudah punya akun? '
                              : 'Belum punya akun? ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isRegister = !_isRegister;
                            _error = null;
                          }),
                          child: Text(
                            _isRegister ? 'Masuk' : 'Daftar',
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}

// INPUT FIELD
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

// PLACEHOLDER PAGES
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
    final filteredMovies = nowShowingMovies
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
              childAspectRatio: 0.95,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        movie.imagePath,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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

class CinemaPage extends StatelessWidget {
  const CinemaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: locationState,
      builder: (context, _) {
        // Ambil data bioskop dari kota yang dipilih di movie_detail_screen.dart
        final cinemas =
            cityCinemas[locationState.selectedCity] ?? cityCinemas['Medan']!;

        return Column(
          children: [
            // Header Search & City (Persis Gambar)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationState.selectedCity,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cinema',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Header Dummy (Movie | Cinema)
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Cinema',
                        style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(height: 2, width: 60, color: Color(0xFF1A237E)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),

            // List Bioskop (Persis Gambar)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cinemas.length,
                itemBuilder: (context, index) {
                  final c = cinemas[index];
                  // Simulasi jarak acak
                  double distance = 18.0 + (index * 1.2);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.cinemaName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_searching,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${distance.toStringAsFixed(2)} km away',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.layers_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            // Ambil tipe screen (REGULAR/IMAX/VIP)
                            Text(
                              c.screenType.split(' ').first,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (c.screenType.contains('IMAX')) ...[
                              const SizedBox(width: 8),
                              Text(
                                'IMAX',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
      },
    );
  }
}

// ─── F&B PAGE FULL FUNGSI ────────────────────────────────────────────────
class FnBPage extends StatefulWidget {
  const FnBPage({super.key});
  @override
  State<FnBPage> createState() => _FnBPageState();
}

class _FnBPageState extends State<FnBPage> {
  String? _selectedCinema;
  final Map<String, int> _cart = {};

  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  int get _totalPrice {
    int total = 0;
    _cart.forEach((id, qty) {
      final item = globalFoodItems.firstWhere((f) => f.id == id);
      total += item.price * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cinemas =
        cityCinemas[locationState.selectedCity] ?? cityCinemas['Medan']!;
    _selectedCinema ??= cinemas.first.cinemaName;

    final exclusiveCombos = globalFoodItems
        .where((f) => f.category == 'exclusive_combo')
        .toList();
    final combos = globalFoodItems.where((f) => f.category == 'combo').toList();
    final drinks = globalFoodItems.where((f) => f.category == 'drink').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Food & Beverages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Dropdown Bioskop
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCinema,
                isExpanded: true,
                items: cinemas
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.cinemaName,
                        child: Text(
                          '${c.cinemaName}, ${locationState.selectedCity}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedCinema = val;
                  _cart.clear(); // Reset cart kalau ganti bioskop
                }),
              ),
            ),
          ),

          // Menu Makanan
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exclusiveCombos.isNotEmpty)
                    _buildFoodSection('- EXCLUSIVE COMBO', exclusiveCombos),
                  if (combos.isNotEmpty) _buildFoodSection('COMBO', combos),
                  if (drinks.isNotEmpty) _buildFoodSection('DRINKS', drinks),
                ],
              ),
            ),
          ),

          // Bottom Bar Cart
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        _formatPrice(_totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FnBOrderSummaryScreen(
                            cinemaName: _selectedCinema!,
                            cart: _cart,
                            total: _totalPrice,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildFoodSection(String title, List<FoodItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final qty = _cart[item.id] ?? 0;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: item.imagePath.isNotEmpty
                          ? Image.asset(
                              item.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(item.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        qty == 0
                            ? SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _cart[item.id] = 1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A237E),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      if (qty > 1)
                                        _cart[item.id] = qty - 1;
                                      else
                                        _cart.remove(item.id);
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A237E),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _cart[item.id] = qty + 1,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A237E),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── F&B ORDER SUMMARY SCREEN ────────────────────────────────────────────────
class FnBOrderSummaryScreen extends StatefulWidget {
  final String cinemaName;
  final Map<String, int> cart;
  final int total;
  const FnBOrderSummaryScreen({
    super.key,
    required this.cinemaName,
    required this.cart,
    required this.total,
  });

  @override
  State<FnBOrderSummaryScreen> createState() => _FnBOrderSummaryScreenState();
}

class _FnBOrderSummaryScreenState extends State<FnBOrderSummaryScreen> {
  String? _selectedPayment;

  // Fungsi Helper
  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _openPaymentMethod() {
    // Pakai Modal sederhana biar ga nyenggol file payment_screen.dart
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['GoPay', 'ShopeePay', 'QRIS', 'Transfer Bank'].map(
              (method) => ListTile(
                title: Text(method),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() => _selectedPayment = method);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ringkasan Order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Banner Merah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFFFCE4EC),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Waiting for Payment  ',
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  '19:59',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Bioskop',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${widget.cinemaName}, ${locationState.selectedCity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Food & Beverages',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // List Makanan
                  ...widget.cart.entries.map((e) {
                    final item = globalFoodItems.firstWhere(
                      (f) => f.id == e.key,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'x ${e.value}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatPrice(item.price)} x ${e.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 30),
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total F&B',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatPrice(widget.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya Layanan(FnB)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Rp 0',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatPrice(widget.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pesanan yang dibeli tidak dapat diubah atau di refund.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(height: 30),

                  // Promo & Bayar
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Promo/Voucher',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Kamu belum memilih promo'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _openPaymentMethod,
                    title: const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      _selectedPayment ?? _formatPrice(widget.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Bawah
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedPayment == null
                    ? null
                    : () {
                        // KITA LANGSUNG KIRIM KE PAYMENT PROCESS SCREEN (Bawaan payment_screen.dart)
                        // Supaya Riwayat, Notif, Lonceng otomatis masuk
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentProcessScreen(
                              movie: const MovieModel(
                                title: 'Pesanan F&B',
                                genre: 'Snack & Drink',
                                imagePath: 'assets/images/Popcorn_Large.png',
                              ), // Movie bayangan buat F&B
                              cinemaName: widget.cinemaName,
                              screenType: 'F&B Pick-up',
                              time: '-',
                              date: DateTime.now(),
                              selectedSeats: const [], // Kursi kosong
                              ticketPrice: 0,
                              foodOrder: widget.cart.entries.map((e) {
                                final item = globalFoodItems.firstWhere(
                                  (f) => f.id == e.key,
                                );
                                return {
                                  'name': item.name,
                                  'qty': e.value,
                                  'price': item.price,
                                };
                              }).toList(),
                              paymentMethod: _selectedPayment!,
                              grandTotal: widget.total,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PROFILE SCREEN - halaman penuh dengan Scaffold sendiri
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: AnimatedBuilder(
        animation: authState,
        builder: (context, _) {
          if (!authState.isLoggedIn) {
            // Jika user logout dari dalam halaman ini, pop otomatis
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }
          return _ProfileBody();
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: authState.username);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF1A237E),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A237E),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: authState.email),
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    authState.login(
                      nameCtrl.text.trim(),
                      authState.email ?? '',
                    );
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara memesan tiket?',
        'a':
            'Pilih film, pilih jadwal dan kursi, lalu lakukan pembayaran. Tiket akan dikirim ke email kamu.',
      },
      {
        'q': 'Apakah tiket bisa dibatalkan?',
        'a':
            'Tiket dapat dibatalkan maksimal 2 jam sebelum jadwal tayang. Pengembalian dana diproses dalam 3-5 hari kerja.',
      },
      {
        'q': 'Metode pembayaran apa saja yang tersedia?',
        'a':
            'Kami menerima transfer bank, e-wallet (GoPay, OVO, Dana), kartu kredit/debit, dan QRIS.',
      },
      {
        'q': 'Bagaimana cara menggunakan kode promo?',
        'a':
            'Masukkan kode promo pada halaman pembayaran di kolom yang tersedia sebelum konfirmasi.',
      },
      {
        'q': 'Tiket saya tidak muncul, apa yang harus dilakukan?',
        'a':
            'Cek email kamu atau hubungi CS kami di cs@tixio.id dengan menyertakan bukti pembayaran.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: faqs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => ExpansionTile(
                    iconColor: const Color(0xFF1A237E),
                    collapsedIconColor: Colors.grey,
                    title: Text(
                      faqs[i]['q']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: Text(
                          faqs[i]['a']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRiwayatPembelian(BuildContext context) {
    // Helper untuk format harga
    String fmtPrice(int p) {
      final s = p.toString();
      if (s.length <= 3) return 'Rp $s';
      final buf = StringBuffer('Rp ');
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        // BUNGKUS PAKAI ANIMATED BUILDER
        builder: (_, scrollCtrl) => AnimatedBuilder(
          animation: bookingState,
          builder: (context, _) {
            // AMBIL DATA ASLI DARI STATE
            final riwayat = bookingState.bookings;

            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Riwayat Pembelian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  // KONDISI JIKA KOSONG
                  child: riwayat.isEmpty
                      ? const Center(
                          child: Text(
                            'Kamu belum pernah membeli tiket.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: riwayat.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            // AMBIL ITEM PER BARIS
                            final item = riwayat[i];
                            final title = (item.movie.title ?? '') as String;

                            // Format Tanggal
                            final d = item.date;
                            final dateStr =
                                '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

                            return Container(
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
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'Berhasil', // Status hardcode sukses
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _RiwayatRow(
                                    icon: Icons.calendar_today_outlined,
                                    text: '$dateStr • ${item.time}',
                                  ),
                                  const SizedBox(height: 4),
                                  _RiwayatRow(
                                    icon: Icons.theaters_outlined,
                                    text: item.cinemaName,
                                  ),
                                  const SizedBox(height: 4),
                                  _RiwayatRow(
                                    icon: Icons.event_seat_outlined,
                                    text: 'Kursi ${item.seats.join(', ')}',
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        fmtPrice(item.grandTotal),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFilmFavorit(BuildContext context) {
    final favorit = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Film Favorit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favorit.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final film = favorit[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        film['imagePath']!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 70,
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          child: const Icon(
                            Icons.movie_outlined,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      film['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          film['genre']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              film['rating']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.pink,
                      ),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHubungiCS(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Supaya modal bisa fleksibel tingginya
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        // Tambahkan padding bawah mengikuti keyboard jika muncul
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Penting agar modal tidak kosong ke bawah
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Hubungi Customer Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tim CS kami siap membantu kamu 24/7',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // List pilihan CS
            _CSOption(
              icon: Icons.chat_bubble_outline_rounded,
              color: Colors.green,
              title: 'WhatsApp',
              subtitle: '+62 812-3456-7890',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.email_outlined,
              color: const Color(0xFF1A237E),
              title: 'Email',
              subtitle: 'cs@tixio.id',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.phone_outlined,
              color: Colors.orange,
              title: 'Telepon',
              subtitle: '1500-123 (Senin–Jumat, 08.00–17.00)',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.chat_outlined,
              color: Colors.purple,
              title: 'Live Chat',
              subtitle: 'Chat langsung di aplikasi',
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showKebijakanPrivasi(BuildContext context) {
    final kebijakan = [
      {
        'judul': '1. Data yang Kami Kumpulkan',
        'isi':
            'Kami mengumpulkan informasi yang kamu berikan saat mendaftar, seperti nama, email, dan nomor telepon. Kami juga mengumpulkan data transaksi pembelian tiket.',
      },
      {
        'judul': '2. Penggunaan Data',
        'isi':
            'Data kamu digunakan untuk memproses transaksi, mengirimkan konfirmasi tiket, dan meningkatkan layanan kami. Kami tidak menjual data pribadi kamu kepada pihak ketiga.',
      },
      {
        'judul': '3. Keamanan Data',
        'isi':
            'Kami menggunakan enkripsi SSL/TLS untuk melindungi data kamu. Semua informasi pembayaran diproses melalui gateway yang tersertifikasi PCI-DSS.',
      },
      {
        'judul': '4. Cookies',
        'isi':
            'Aplikasi kami menggunakan cookies untuk meningkatkan pengalaman pengguna dan menganalisis trafik. Kamu dapat menonaktifkan cookies melalui pengaturan perangkat.',
      },
      {
        'judul': '5. Hak Kamu',
        'isi':
            'Kamu berhak mengakses, memperbarui, atau menghapus data pribadi kamu kapan saja. Hubungi cs@tixio.id untuk permintaan terkait data.',
      },
      {
        'judul': '6. Perubahan Kebijakan',
        'isi':
            'Kami dapat memperbarui kebijakan privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui email atau notifikasi aplikasi.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kebijakan Privasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                'Terakhir diperbarui: 1 Januari 2025',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: kebijakan.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kebijakan[i]['judul']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kebijakan[i]['isi']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun Tixio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              authState.logout();
              Navigator.pop(ctx); // tutup dialog
              Navigator.pop(context); // kembali ke Home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = authState.username ?? '';
    final email = authState.email ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CustomScrollView(
      slivers: [
        // APP BAR dengan header profil
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFF1A237E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profil Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // BODY ISI
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // SEKSI AKUN
                _SectionLabel('Akun'),
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF1A237E),
                      label: 'Edit Profil',
                      onTap: () => _showEditProfile(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.confirmation_number_outlined,
                      iconColor: Colors.orange,
                      label: 'Riwayat Pembelian',
                      onTap: () => _showRiwayatPembelian(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.favorite_border_rounded,
                      iconColor: Colors.pink,
                      label: 'Film Favorit',
                      onTap: () => _showFilmFavorit(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SEKSI BANTUAN
                _SectionLabel('Bantuan'),
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.purple,
                      label: 'FAQ',
                      onTap: () => _showFAQ(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.headset_mic_outlined,
                      iconColor: Colors.green,
                      label: 'Hubungi CS',
                      onTap: () => _showHubungiCS(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.policy_outlined,
                      iconColor: Colors.indigo,
                      label: 'Kebijakan Privasi',
                      onTap: () => _showKebijakanPrivasi(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.blueGrey,
                      label: 'Tentang Tixio',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Tixio',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(
                          Icons.movie_filter_rounded,
                          color: Color(0xFF1A237E),
                          size: 48,
                        ),
                        children: const [
                          Text(
                            'Tixio adalah aplikasi pembelian tiket bioskop yang mudah, cepat, dan terpercaya.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// HELPER WIDGETS untuk ProfileScreen
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.6,
      ),
    ),
  );
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, indent: 56, color: Colors.grey.shade100);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    trailing:
        trailing ??
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
  );
}

// PROFILE PAGE - tab wrapper (tetap ada untuk bottom nav)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        if (!authState.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Belum Masuk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk melihat profil kamu',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk / Daftar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        // Sudah login: tampilkan isi profil langsung (embedded, tanpa AppBar)
        return _ProfileBody();
      },
    );
  }
}

// RIWAYAT ROW HELPER
class _RiwayatRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RiwayatRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );
}

// CS OPTION HELPER
class _CSOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CSOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            // Bungkus Column dengan Expanded agar sisa space dihitung benar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    // Teks ini sekarang akan otomatis turun ke bawah jika kepanjangan
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFF1A237E).withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Segera hadir di Tixio!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── NOTIFICATION SCREEN ──────────────────────────────────────────────────────
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: bookingState,
        builder: (context, _) {
          // Kita ambil data tiket dari bookings aja biar infonya lengkap
          final bookings = bookingState.bookings;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: const Color(0xFF1A237E).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pesan tiket film pertamamu sekarang!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final title = (b.movie.title ?? '') as String;

              // Format tanggal untuk nampilin "kapan notif masuk" (simulasi)
              final d = b.bookedAt;
              final timeStr =
                  '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon sukses
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Detail text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pembelian Tiket Berhasil!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Cari di NotificationScreen bagian RichText:
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.4,
                              ),
                              children: b.seats.isEmpty
                                  ? [
                                      const TextSpan(text: 'Pesanan '),
                                      const TextSpan(
                                        text: 'F&B kamu ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: 'di '),
                                      TextSpan(
                                        text: b.cinemaName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' sudah dikonfirmasi. Selamat menikmati!',
                                      ),
                                    ]
                                  : [
                                      const TextSpan(
                                        text: 'Hore! Kamu berhasil membeli ',
                                      ),
                                      TextSpan(
                                        text: '${b.seats.length} tiket',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' untuk film '),
                                      TextSpan(
                                        text: title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '. Selamat menonton!',
                                      ),
                                    ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── CITY SELECTION SCREEN (TAMBAHKAN DI PALING BAWAH main.dart) ───
class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});
  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  late String _tempCity;
  String _tempType = 'REGULAR'; // Visual dummy untuk Type

  final List<String> _types = [
    'REGULAR',
    'MACRO XE',
    'VIP',
    'JUNIOR',
    'JOMO',
    'LUXE',
    'COMFORT',
  ];
  // 10 Kota Sesuai Request
  final List<String> _cities = [
    'Bali',
    'Balikpapan',
    'Bandung',
    'Batam',
    'Bekasi',
    'Bogor',
    'Jakarta',
    'Makassar',
    'Medan',
    'Palembang',
  ];

  @override
  void initState() {
    super.initState();
    _tempCity = locationState.selectedCity;
  }

  @override
  Widget build(BuildContext context) {
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
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: '',
                      prefixIcon: const Icon(Icons.search, size: 28),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TYPE SECTION
                  const Text(
                    'Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _types
                        .map(
                          (type) => GestureDetector(
                            onTap: () => setState(() => _tempType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _tempType == type
                                    ? Colors.white
                                    : Colors.white,
                                border: Border.all(
                                  color: _tempType == type
                                      ? const Color(0xFF1A237E)
                                      : Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: _tempType == type
                                      ? const Color(0xFF1A237E)
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),

                  // CITY SECTION
                  const Text(
                    'City',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cities
                        .map(
                          (city) => GestureDetector(
                            onTap: () => setState(() => _tempCity = city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _tempCity == city
                                    ? const Color(0xFF0A1B3F)
                                    : Colors.white,
                                border: Border.all(
                                  color: _tempCity == city
                                      ? const Color(0xFF0A1B3F)
                                      : Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                city,
                                style: TextStyle(
                                  color: _tempCity == city
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM BUTTONS (Reset & Apply)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _tempCity = 'Medan'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      locationState.setCity(
                        _tempCity,
                      ); // Simpan kota ke state global
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1B3F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}
