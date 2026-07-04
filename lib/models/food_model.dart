class FoodItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final String imagePath;
  final String? description;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath = '',
    this.description,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      imagePath: map['imagePath'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imagePath': imagePath,
      'description': description,
    };
  }
}
