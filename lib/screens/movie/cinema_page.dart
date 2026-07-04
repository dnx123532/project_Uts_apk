import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/providers/cinema_provider.dart';
import 'package:project_uts_apk/screens/country/city_selection_screen.dart';
import 'cinema_detail_screen.dart';

class CinemaPage extends StatefulWidget {
  const CinemaPage({super.key});

  @override
  State<CinemaPage> createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: locationState,
      builder: (context, _) {
        final cinemaProvider = context.watch<CinemaProvider>();
        final allCinemas = cinemaProvider.getByCity(locationState.selectedCity);
        final cinemas = _search.isEmpty
            ? allCinemas
            : allCinemas
                .where((c) => c.cinemaName.toLowerCase().contains(_search.toLowerCase()))
                .toList();

        if (cinemaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // ── Kota — bisa diklik ────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
                    ).then((_) => setState(() {})),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF1A237E)),
                        const SizedBox(width: 4),
                        AnimatedBuilder(
                          animation: locationState,
                          builder: (_, child) => Text(
                            locationState.selectedCity,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A237E)),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A237E)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Search bar ────────────────────────────────────────
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Cari bioskop...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Tab header ────────────────────────────────────────────────
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cinema', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 4),
                Container(height: 2, color: const Color(0xFF1A237E), margin: const EdgeInsets.only(left: 16, right: 16)),
              ],
            ),
            const Divider(height: 1),
            // ── List bioskop ──────────────────────────────────────────────
            cinemas.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text('Tidak ada bioskop tersedia', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cinemas.length,
                      itemBuilder: (context, index) {
                        final c = cinemas[index];
                        final distance = 18.0 + (index * 1.2);

                        final imgPath = CinemaDetailScreen.imageFor(c.cinemaName);
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CinemaDetailScreen(
                                cinemaName: c.cinemaName,
                                screenType: c.screenType,
                                city: locationState.selectedCity,
                                distance: distance,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail gambar bioskop
                                if (imgPath != null)
                                  Stack(
                                    children: [
                                      Image.network(
                                        imgPath,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, e, s) => Container(
                                          height: 120,
                                          color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                                          child: const Center(child: Icon(Icons.theaters_outlined, color: Color(0xFF1A237E), size: 40)),
                                        ),
                                      ),
                                      // Badge tipe layar
                                      Positioned(
                                        bottom: 8, left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A237E).withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            c.screenType,
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(c.cinemaName,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_searching, size: 13, color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text('${distance.toStringAsFixed(1)} km away',
                                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          const SizedBox(width: 12),
                                          if (imgPath == null) ...[
                                            const Icon(Icons.layers_outlined, size: 13, color: Colors.grey),
                                            const SizedBox(width: 5),
                                            Text(c.screenType,
                                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
