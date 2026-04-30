// ─── F&B PAGE FULL FUNGSI ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/cinema_city_data.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/models/food_model.dart';
import 'package:project_uts_apk/screens/food_and_beverages/fnb_order_summary_screen.dart';
import 'package:project_uts_apk/screens/food_and_beverages/food_and_beverage_screen.dart';

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
                                      if (qty > 1) {
                                        _cart[item.id] = qty - 1;
                                      } else {
                                        _cart.remove(item.id);
                                      }
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
