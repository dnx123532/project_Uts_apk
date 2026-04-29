// ─── DATA MODEL MAKANAN ────────────────────────────────────────────────────────
class FoodItem {
  final String id;
  final String name;
  final String
  category; // 'recommended', 'exclusive_combo', 'combo', 'snack', 'drink'
  final int price;
  final String imagePath; // kosong jika belum ada gambar
  final String? description;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath = '',
    this.description,
  });
}
