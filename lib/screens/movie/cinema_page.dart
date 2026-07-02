import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/data/cinema_city_data.dart';
import 'package:flutter_application_for_us/data/data_film.dart';

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
