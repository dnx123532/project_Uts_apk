// ─── CITY SELECTION SCREEN (TAMBAHKAN DI PALING BAWAH main.dart) ───
import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';

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
