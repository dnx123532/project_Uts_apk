import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts_apk/providers/movie_provider.dart';
import 'package:project_uts_apk/models/movie_models.dart';
import 'movie_detail_screen.dart';

class CinemaDetailScreen extends StatelessWidget {
  final String cinemaName;
  final String screenType;
  final String city;
  final double distance;

  const CinemaDetailScreen({
    super.key,
    required this.cinemaName,
    required this.screenType,
    required this.city,
    required this.distance,
  });

  // Cocokkan nama bioskop ke file gambar di assets/images
  static const _imageMap = {
    'grand indonesia':    'assets/images/Grand_Indonesia.jpg',
    'senayan city':       'assets/images/Senayan_city.jpg',
    'kelapa gading':      'assets/images/Kelapa_Gading.jpg',
    'ciwalk':             'assets/images/Ciwalk_Bandung.jpg',
    'paris van java':     'assets/images/Paris_Van_Java.jpeg',
    'trans studio':       'assets/images/TransStudio Mall.jpg',
    'pentacity':          'assets/images/Pentacity.jpg',
    'e-walk':             'assets/images/E-Walk.jpg',
    'mega mall':          'assets/images/Mega Mall.jpg',
    'grand batam':        'assets/images/Grand Batam Mall.png',
    'batam mall':         'assets/images/Batam Mall.jpg',
    'summarecon':         'assets/images/Summarecon Mall.jpg',
    'mega bekasi':        'assets/images/Mega Bekasi.jpg',
    'bekasi':             'assets/images/Bekasi.jpg',
    'botani':             'assets/images/Botani.jpg',
    'cibinong':           'assets/images/Cibinong City.jpg',
    'panakkukang':        'assets/images/panukkanga.jpg',
    'palembang icon':     'assets/images/Palembang-Icon-Mall-PhotoRoom.jpg',
    'palembang square':   'assets/images/Palembang-Square-PhotoRoom.jpg',
    'medan fair':         'assets/images/Medan Fair.jpg',
    'lippo':              'assets/images/Lippo.jpeg',
    'sun plaza':          'assets/images/SunPlaza.jpeg',
    'hermes':             'assets/images/Hermes Place.jpg',
    'bogor':              'assets/images/Bogor.png',
  };

  static String? imageFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _imageMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  String? get _imagePath => imageFor(cinemaName);

  String get _description {
    final name = cinemaName.toLowerCase();
    if (name.contains('imax')) {
      return 'Bioskop dengan teknologi layar IMAX terbesar di $city. '
          'Dilengkapi sistem suara surround 12-channel dan layar raksasa '
          'hingga 23 meter, memberikan pengalaman sinema yang tak tertandingi.';
    } else if (name.contains('4dx')) {
      return 'Bioskop 4DX di $city menghadirkan pengalaman sinema '
          'multi-sensori dengan kursi bergerak, efek angin, air, aroma, '
          'dan cahaya yang sinkron dengan adegan film.';
    } else if (name.contains('premiere') || name.contains('gold')) {
      return 'Bioskop premium di $city dengan kursi sofa mewah, '
          'layanan butler pribadi, dan menu makanan eksklusif. '
          'Nikmati film favoritmu dalam suasana VIP yang nyaman.';
    } else if (name.contains('xxi') || name.contains('21')) {
      return 'Cinema XXI $city adalah jaringan bioskop terkemuka '
          'dengan standar internasional. Dilengkapi teknologi digital '
          'terkini dan sistem tata suara Dolby Digital.';
    } else if (name.contains('cgv')) {
      return 'CGV $city menghadirkan pengalaman menonton film modern '
          'dengan teknologi layar dan suara terdepan. Tersedia berbagai '
          'pilihan format dari Regular hingga Starium dan 4DX.';
    } else if (name.contains('cinemaxx') || name.contains('lippo')) {
      return 'CinemaXX $city menawarkan pengalaman bioskop premium '
          'dengan fasilitas lengkap dan tata ruang yang nyaman '
          'untuk semua kalangan.';
    } else {
      return 'Bioskop $cinemaName di $city menghadirkan pengalaman '
          'menonton film terbaik dengan teknologi audio-visual modern '
          'dan kenyamanan ruang yang optimal untuk seluruh keluarga.';
    }
  }

  String get _facilities {
    final type = screenType.toUpperCase();
    if (type.contains('IMAX')) return 'IMAX · Dolby Atmos · 23m Screen';
    if (type.contains('4DX')) return '4DX · Motion Seat · Multi-Sensory';
    if (type.contains('GOLD') || type.contains('PREMIERE')) return 'Sofa Seat · Butler Service · VIP Lounge';
    return 'Digital · Dolby Sound · AC';
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final movies = movieProvider.movies;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                cinemaName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imagePath != null)
                    Image.asset(
                      _imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, stack) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF283593)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF283593)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  // Overlay gelap agar teks judul tetap terbaca
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info bioskop ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card lokasi & tipe
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Color(0xFF1A237E)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$city · ${distance.toStringAsFixed(1)} km',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.layers_outlined, size: 16, color: Color(0xFF1A237E)),
                            const SizedBox(width: 6),
                            Text(
                              screenType,
                              style: const TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star_outline, size: 16, color: Color(0xFF1A237E)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _facilities,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text(
                    'Tentang Bioskop',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      _description,
                      style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header film yang tayang
                  const Text(
                    'Film yang Tayang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk film untuk melihat detail dan jadwal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Grid film ────────────────────────────────────────────────
          movieProvider.isLoading
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
                  ),
                )
              : movies.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('Tidak ada film tersedia', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _MovieCard(movie: movies[index]),
                          childCount: movies.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.55,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildPoster(movie.imagePath),
            ),
          ),
          const SizedBox(height: 6),
          // Judul
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Rating
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                movie.rating.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, e) => _placeholder(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, e) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.movie, color: Colors.grey)),
    );
  }
}
