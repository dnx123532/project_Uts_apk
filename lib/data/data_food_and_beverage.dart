// ── DATA MAKANAN — ISI SESUAI MENU ──────────────────────────────────────────
// Ganti list di bawah ini dengan menu yang sebenarnya
import 'package:project_uts_apk/models/food_model.dart';

final List<FoodItem> allFoodItems = [
  // RECOMMENDED (muncul di bagian atas jika ada item di cart)
  FoodItem(
    id: 'rec_001',
    name: 'Paket Hemat Spesial',
    category: 'recommended',
    price: 85000,
    imagePath:
        'assets/images/Combo_1.png', // ganti dengan path gambar, e.g. 'assets/food/paket_hemat.png'
    description: 'Popcorn medium + 2 minuman',
  ),

  // EXCLUSIVE COMBO
  FoodItem(
    id: 'exc_001',
    name: 'Online Exclusive Combo Sweet',
    category: 'exclusive_combo',
    price: 104000,
    imagePath:
        'assets/images/online_exclusive combo _sweeet.png', // ganti dengan path gambar
    description: 'Popcorn large + 2 Coca-Cola + Pocky + Nugget',
  ),
  FoodItem(
    id: 'exc_002',
    name: 'Online Exclusive Combo Savory',
    category: 'exclusive_combo',
    price: 99000,
    imagePath: 'assets/images/combo_savory.png', // ganti dengan path gambar
    description: 'Popcorn large + 2 Coca-Cola + Chicken Strip',
  ),
  FoodItem(
    id: 'exc_003',
    name: 'Online Exclusive Combo Duo',
    category: 'exclusive_combo',
    price: 119000,
    imagePath:
        'assets/images/online_exclusive_combo_2.png', // ganti dengan path gambar
    description: 'Popcorn XL + 2 Coca-Cola + Snack pilihan',
  ),

  // COMBO
  FoodItem(
    id: 'cmb_001',
    name: 'Combo 1 - Popcorn + Minuman',
    category: 'combo',
    price: 65000,
    imagePath:
        'assets/images/Combo1_Popcorn_ Minuman.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'cmb_002',
    name: 'Combo 2 - Popcorn Besar + 2 Minuman',
    category: 'combo',
    price: 79000,
    imagePath:
        'assets/images/Combo_2_Popcorn_Besar_2_Minuman.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'cmb_003',
    name: 'Combo 3 - Family Pack',
    category: 'combo',
    price: 145000,
    imagePath:
        'assets/images/Combo 3_Family_Pack.png', // ganti dengan path gambar
  ),

  // SNACK
  FoodItem(
    id: 'snk_001',
    name: 'Popcorn Small',
    category: 'snack',
    price: 32000,
    imagePath: 'assets/images/Popcorn_Small.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_002',
    name: 'Popcorn Medium',
    category: 'snack',
    price: 42000,
    imagePath: 'assets/images/Popcorn_Medium.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_003',
    name: 'Popcorn Large',
    category: 'snack',
    price: 55000,
    imagePath: 'assets/images/Popcorn_Large.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_004',
    name: 'Nachos + Cheese',
    category: 'snack',
    price: 38000,
    imagePath: 'assets/images/Nachos_+_Cheese.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'snk_005',
    name: 'Hot Dog',
    category: 'snack',
    price: 35000,
    imagePath: 'assets/images/HotDog.png', // ganti dengan path gambar
  ),

  // DRINK
  FoodItem(
    id: 'drk_001',
    name: 'Coca-Cola Regular',
    category: 'drink',
    price: 22000,
    imagePath:
        'assets/images/Coca-Cola_Regular.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_002',
    name: 'Coca-Cola Large',
    category: 'drink',
    price: 28000,
    imagePath: 'assets/images/Coca-Cola_Large.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_003',
    name: 'Air Mineral',
    category: 'drink',
    price: 15000,
    imagePath: 'assets/images/Air_Mineral.png', // ganti dengan path gambar
  ),
  FoodItem(
    id: 'drk_004',
    name: 'Juice Jeruk',
    category: 'drink',
    price: 30000,
    imagePath: 'assets/images/Juice_Jeruk.png', // ganti dengan path gambar
  ),
];
