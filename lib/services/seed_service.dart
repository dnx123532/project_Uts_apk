import 'package:flutter/foundation.dart';
import '../models/movie_models.dart';
import '../models/food_model.dart';
import '../models/cinema_model.dart';
import 'firestore_service.dart';

class SeedService {
  final FirestoreService _firestore = FirestoreService();

  // Cek langsung ke Firestore — seed jika koleksi masih kosong
  Future<void> seedIfNeeded() async {
    debugPrint('🔄 Checking Firestore...');

    final foods = await _firestore.getFoodItems();
    debugPrint('📦 Food items in Firestore: ${foods.length}');
    if (foods.isEmpty) {
      await _firestore.saveFoodItems(_foodItems);
      debugPrint('✅ Food items seeded: ${_foodItems.length} items');
    }

    final cinemas = await _firestore.getCinemas();
    debugPrint('🎬 Cinemas in Firestore: ${cinemas.length}');
    if (cinemas.isEmpty) {
      await _firestore.saveCinemas(_cinemas);
      debugPrint('✅ Cinemas seeded: ${_cinemas.length} cities');
    }
  }

  // ── DATA SEED (juga dipakai sebagai fallback di provider) ──────────────────
  static List<FoodItem> get foodItems => _foodItems;
  static Map<String, List<CinemaSchedule>> get cinemaData => _cinemas;
  static List<MovieModel> get upcomingMovies => _upcomingMovies;

  static final List<MovieModel> _upcomingMovies = [
    const MovieModel(
      title: 'Upcoming 1',
      genre: 'Genre',
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/upcoming1.jpg',
      duration: 'Coming Soon',
      rating: 0,
    ),
    const MovieModel(
      title: 'Upcoming 2',
      genre: 'Genre',
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/upcoming2.jpg',
      duration: 'Coming Soon',
      rating: 0,
    ),
  ];

  static final List<FoodItem> _foodItems = [
    const FoodItem(
      id: 'rec_001',
      name: 'Paket Hemat Spesial',
      category: 'recommended',
      price: 85000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Combo_1.png',
      description: 'Popcorn medium + 2 minuman',
    ),
    const FoodItem(
      id: 'exc_001',
      name: 'Online Exclusive Combo Sweet',
      category: 'exclusive_combo',
      price: 104000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/online_exclusive combo _sweeet.png',
      description: 'Popcorn large + 2 Coca-Cola + Pocky + Nugget',
    ),
    const FoodItem(
      id: 'exc_002',
      name: 'Online Exclusive Combo Savory',
      category: 'exclusive_combo',
      price: 99000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/combo_savory.png',
      description: 'Popcorn large + 2 Coca-Cola + Chicken Strip',
    ),
    const FoodItem(
      id: 'exc_003',
      name: 'Online Exclusive Combo Duo',
      category: 'exclusive_combo',
      price: 119000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/online_exclusive_combo_2.png',
      description: 'Popcorn XL + 2 Coca-Cola + Snack pilihan',
    ),
    const FoodItem(
      id: 'cmb_001',
      name: 'Combo 1 - Popcorn + Minuman',
      category: 'combo',
      price: 65000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Combo1_Popcorn_ Minuman.png',
    ),
    const FoodItem(
      id: 'cmb_002',
      name: 'Combo 2 - Popcorn Besar + 2 Minuman',
      category: 'combo',
      price: 79000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Combo_2_Popcorn_Besar_2_Minuman.png',
    ),
    const FoodItem(
      id: 'cmb_003',
      name: 'Combo 3 - Family Pack',
      category: 'combo',
      price: 145000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Combo 3_Family_Pack.png',
    ),
    const FoodItem(
      id: 'snk_001',
      name: 'Popcorn Small',
      category: 'snack',
      price: 32000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Popcorn_Small.png',
    ),
    const FoodItem(
      id: 'snk_002',
      name: 'Popcorn Medium',
      category: 'snack',
      price: 42000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Popcorn_Medium.png',
    ),
    const FoodItem(
      id: 'snk_003',
      name: 'Popcorn Large',
      category: 'snack',
      price: 55000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Popcorn_Large.png',
    ),
    const FoodItem(
      id: 'snk_004',
      name: 'Nachos + Cheese',
      category: 'snack',
      price: 38000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Nachos_+_Cheese.png',
    ),
    const FoodItem(
      id: 'snk_005',
      name: 'Hot Dog',
      category: 'snack',
      price: 35000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/HotDog.png',
    ),
    const FoodItem(
      id: 'drk_001',
      name: 'Coca-Cola Regular',
      category: 'drink',
      price: 22000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Coca-Cola_Regular.png',
    ),
    const FoodItem(
      id: 'drk_002',
      name: 'Coca-Cola Large',
      category: 'drink',
      price: 28000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Coca-Cola_Large.png',
    ),
    const FoodItem(
      id: 'drk_003',
      name: 'Air Mineral',
      category: 'drink',
      price: 15000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Air_Mineral.png',
    ),
    const FoodItem(
      id: 'drk_004',
      name: 'Juice Jeruk',
      category: 'drink',
      price: 30000,
      imagePath: 'https://cdn.jsdelivr.net/gh/dnx123532/video_and_image@main/images/Juice_Jeruk.png',
    ),
  ];

  // ── DATA SEED BIOSKOP ────────────────────────────────────────────────────────
  static final Map<String, List<CinemaSchedule>> _cinemas = {
    'Jakarta': [
      const CinemaSchedule(cinemaName: 'Grand Indonesia', screenType: 'REGULAR 2D', price: 60000, times: ['12:00', '14:30', '17:00', '19:30']),
      const CinemaSchedule(cinemaName: 'Senayan City', screenType: 'IMAX 2D', price: 85000, times: ['13:00', '16:00', '19:00']),
      const CinemaSchedule(cinemaName: 'Kelapa Gading', screenType: 'VIP 2D', price: 120000, times: ['14:00', '18:00', '20:30']),
    ],
    'Bandung': [
      const CinemaSchedule(cinemaName: 'Ciwalk', screenType: 'REGULAR 2D', price: 45000, times: ['12:30', '15:00', '18:00', '20:30']),
      const CinemaSchedule(cinemaName: 'Paris Van Java', screenType: 'REGULAR 2D', price: 50000, times: ['13:15', '16:15', '19:15']),
      const CinemaSchedule(cinemaName: 'Trans Studio Mall', screenType: 'MACRO XE', price: 65000, times: ['14:00', '17:30']),
    ],
    'Bali': [
      const CinemaSchedule(cinemaName: 'Beachwalk', screenType: 'REGULAR 2D', price: 60000, times: ['13:00', '16:00', '19:00']),
      const CinemaSchedule(cinemaName: 'Level 21', screenType: 'REGULAR 2D', price: 55000, times: ['12:30', '15:30', '18:30']),
    ],
    'Balikpapan': [
      const CinemaSchedule(cinemaName: 'Pentacity', screenType: 'REGULAR 2D', price: 50000, times: ['12:00', '14:30', '17:00']),
      const CinemaSchedule(cinemaName: 'E-Walk', screenType: 'REGULAR 2D', price: 45000, times: ['13:00', '15:30', '18:00']),
    ],
    'Batam': [
      const CinemaSchedule(cinemaName: 'Mega Mall', screenType: 'REGULAR 2D', price: 40000, times: ['12:15', '15:15', '18:15']),
      const CinemaSchedule(cinemaName: 'Grand Batam Mall', screenType: 'REGULAR 2D', price: 45000, times: ['13:30', '16:30', '19:30']),
    ],
    'Bekasi': [
      const CinemaSchedule(cinemaName: 'Summarecon Mall', screenType: 'IMAX 2D', price: 65000, times: ['12:00', '15:00', '18:00']),
      const CinemaSchedule(cinemaName: 'Mega Bekasi', screenType: 'REGULAR 2D', price: 40000, times: ['13:00', '15:30', '18:30']),
    ],
    'Bogor': [
      const CinemaSchedule(cinemaName: 'Botani Square', screenType: 'REGULAR 2D', price: 45000, times: ['12:45', '15:45', '18:45']),
      const CinemaSchedule(cinemaName: 'Cibinong City', screenType: 'REGULAR 2D', price: 40000, times: ['13:15', '16:15', '19:15']),
    ],
    'Makassar': [
      const CinemaSchedule(cinemaName: 'Trans Studio Mall', screenType: 'REGULAR 2D', price: 50000, times: ['12:00', '14:30', '17:00']),
      const CinemaSchedule(cinemaName: 'Panakkukang', screenType: 'REGULAR 2D', price: 45000, times: ['13:00', '15:30', '18:00']),
    ],
    'Palembang': [
      const CinemaSchedule(cinemaName: 'Palembang Icon', screenType: 'REGULAR 2D', price: 45000, times: ['12:30', '15:00', '17:30']),
      const CinemaSchedule(cinemaName: 'Palembang Square', screenType: 'REGULAR 2D', price: 40000, times: ['13:00', '15:30', '18:00']),
    ],
    'Medan': [
      const CinemaSchedule(cinemaName: 'Plaza Medan Fair', screenType: 'REGULAR 2D', price: 44000, times: ['12:00', '13:25', '14:25', '16:50', '19:15', '21:40']),
      const CinemaSchedule(cinemaName: 'Lippo Plaza Medan', screenType: 'REGULAR 2D', price: 37000, times: ['12:00', '14:20', '16:40', '19:00']),
      const CinemaSchedule(cinemaName: 'Sun Plaza', screenType: 'IMAX 2D', price: 65000, times: ['13:00', '16:00', '20:00']),
      const CinemaSchedule(cinemaName: 'Hermes Place', screenType: 'REGULAR 2D', price: 35000, times: ['13:30', '16:00', '18:30']),
    ],
  };
}
