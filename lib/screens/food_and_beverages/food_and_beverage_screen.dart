// ─── FOOD & BEVERAGES SCREEN ───────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/data/data_food_and_beverage.dart';
import 'package:flutter_application_for_us/models/food_model.dart';
import 'package:flutter_application_for_us/screens/payments/payment_screen.dart';
import 'package:flutter_application_for_us/widgets/qty_control.dart';
import 'package:flutter_application_for_us/widgets/time_banner.dart';

class FoodBeveragesScreen extends StatefulWidget {
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> selectedSeats;
  final int ticketPrice;

  const FoodBeveragesScreen({
    super.key,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.selectedSeats,
    required this.ticketPrice,
  });

  @override
  State<FoodBeveragesScreen> createState() => _FoodBeveragesScreenState();
}

class _FoodBeveragesScreenState extends State<FoodBeveragesScreen> {
  // Cart: id -> qty
  final Map<String, int> _cart = {};

  // Countdown timer (5 menit)
  static const int _totalSeconds = 5 * 60;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  // Recommended item (item pertama di cart, atau default)
  String? _recommendedId;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Default recommended item
    final recs = allFoodItems
        .where((f) => f.category == 'recommended')
        .toList();
    if (recs.isNotEmpty) _recommendedId = recs.first.id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        // Kembali ke home jika timeout
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // ── Helpers ──
  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatPrice(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    final len = s.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}.${(d.month).toString().padLeft(2, '0')}.${d.year}';
  }

  int get _totalFoodPrice {
    int total = 0;
    _cart.forEach((id, qty) {
      final item = allFoodItems.firstWhere(
        (f) => f.id == id,
        orElse: () => FoodItem(id: '', name: '', category: '', price: 0),
      );
      total += item.price * qty;
    });
    return total;
  }

  int get _ticketTotal => widget.selectedSeats.length * widget.ticketPrice;
  int get _grandTotal => _ticketTotal + _totalFoodPrice;

  bool get _hasItemInCart => _cart.values.any((q) => q > 0);

  void _addToCart(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if ((_cart[id] ?? 0) <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]! - 1;
      }
    });
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String title = (movie.title ?? '') as String;
    final String imagePath = (movie.imagePath ?? '') as String;

    // Kelompokkan item per kategori
    final exclusiveCombos = allFoodItems
        .where((f) => f.category == 'exclusive_combo')
        .toList();
    final combos = allFoodItems.where((f) => f.category == 'combo').toList();
    final snacks = allFoodItems.where((f) => f.category == 'snack').toList();
    final drinks = allFoodItems.where((f) => f.category == 'drink').toList();

    // Recommended item (tampilkan jika ada item di cart ATAU default pertama)
    FoodItem? recommendedItem;
    if (_hasItemInCart) {
      // Tampilkan item pertama di cart sebagai recommended
      final firstCartId = _cart.keys.first;
      try {
        recommendedItem = allFoodItems.firstWhere((f) => f.id == firstCartId);
      } catch (_) {}
    } else if (_recommendedId != null) {
      try {
        recommendedItem = allFoodItems.firstWhere(
          (f) => f.id == _recommendedId,
        );
      } catch (_) {}
    }

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
          'Food & Beverages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timer Banner ──
                  TimerBanner(
                    timerText: _timerText,
                    remainingSeconds: _remainingSeconds,
                  ),

                  // ── Info Film + Booking ──
                  _buildBookingInfo(title, imagePath),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // ── Recommended ──
                  if (recommendedItem != null) ...[
                    _buildSectionHeader('Recommended'),
                    _buildRecommendedCard(recommendedItem),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),
                  ],

                  // ── Exclusive Combo ──
                  if (exclusiveCombos.isNotEmpty) ...[
                    _buildSectionLabel('- EXCLUSIVE COMBO'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(exclusiveCombos),
                    const SizedBox(height: 20),
                  ],

                  // ── Combo ──
                  if (combos.isNotEmpty) ...[
                    _buildSectionLabel('COMBO'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(combos),
                    const SizedBox(height: 20),
                  ],

                  // ── Snack ──
                  if (snacks.isNotEmpty) ...[
                    _buildSectionLabel('SNACK'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(snacks),
                    const SizedBox(height: 20),
                  ],

                  // ── Drink ──
                  if (drinks.isNotEmpty) ...[
                    _buildSectionLabel('DRINK'),
                    const SizedBox(height: 12),
                    _buildHorizontalGrid(drinks),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom Bar ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Booking Info ──
  Widget _buildBookingInfo(String title, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    width: 80,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderPoster(),
                  )
                : _placeholderPoster(),
          ),
          const SizedBox(width: 14),
          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _infoRow(Icons.location_on_outlined, widget.cinemaName),
                const SizedBox(height: 6),
                _infoRow(
                  Icons.confirmation_number_outlined,
                  '${widget.screenType.split(' ').first}, CINEMA${widget.selectedSeats.isNotEmpty ? _getCinemaNumber() : ''}',
                ),
                const SizedBox(height: 6),
                _infoRow(
                  Icons.calendar_today_outlined,
                  '${_formatDate(widget.date)} - ${widget.time}',
                ),
                const SizedBox(height: 12),
                // Skip to payment button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Skip To Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  String _getCinemaNumber() {
    // Simulasi nomor studio
    final hash = widget.cinemaName.length + widget.time.hashCode.abs() % 10;
    return '0${(hash % 9) + 1}';
  }

  Widget _placeholderPoster() {
    return Container(
      width: 80,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.movie, color: Colors.grey, size: 32),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  // ── Section Header (Recommended) ──
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: () => _goToPayment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommended Card ──
  Widget _buildRecommendedCard(FoodItem item) {
    final qty = _cart[item.id] ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar
          _buildFoodImage(item, 70, 70),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Qty control
          Column(
            children: [
              QtyControl(
                qty: qty,
                onAdd: () => _addToCart(item.id),
                onRemove: () => _removeFromCart(item.id),
              ),
              if (qty > 0) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showEditDialog(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Label ──
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Horizontal Grid (2 kolom) ──
  Widget _buildHorizontalGrid(List<FoodItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _buildFoodCard(item)).toList(),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    final qty = _cart[item.id] ?? 0;
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: _buildFoodImage(item, 170, 140),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                QtyControl(
                  qty: qty,
                  onAdd: () => _addToCart(item.id),
                  onRemove: () => _removeFromCart(item.id),
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(FoodItem item, double w, double h) {
    if (item.imagePath.isNotEmpty) {
      return Image.asset(
        item.imagePath,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _foodPlaceholder(w, h),
      );
    }
    return _foodPlaceholder(w, h);
  }

  Widget _foodPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood_rounded,
            color: Colors.grey.shade400,
            size: h * 0.3,
          ),
          const SizedBox(height: 4),
          Text(
            'Foto\nsegera hadir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ──
  Widget _buildBottomBar() {
    final cartCount = _cart.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary kursi
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.event_seat_rounded,
                  size: 15,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${widget.selectedSeats.join(', ')} — ${_formatPrice(_ticketTotal)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A237E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (cartCount > 0) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.fastfood_rounded,
                    size: 15,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$cartCount item F&B — ${_formatPrice(_totalFoodPrice)}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    _formatPrice(_grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    '${widget.selectedSeats.length} tiket${cartCount > 0 ? ' + $cartCount F&B' : ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              // Checkout button
              ElevatedButton(
                onPressed: _goToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  cartCount > 0 ? 'Checkout' : 'Lanjut Bayar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Actions ──
  void _goToPayment() {
    _timer?.cancel();
    final foodOrder = _cart.entries.where((e) => e.value > 0).map((e) {
      final item = allFoodItems.firstWhere((f) => f.id == e.key);
      return {'name': item.name, 'qty': e.value, 'price': item.price};
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSummaryScreen(
          movie: widget.movie,
          cinemaName: widget.cinemaName,
          screenType: widget.screenType,
          time: widget.time,
          date: widget.date,
          selectedSeats: widget.selectedSeats,
          ticketPrice: widget.ticketPrice,
          foodOrder: foodOrder,
        ),
      ),
    );
  }

  void _showEditDialog(FoodItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (ctx, setLocalState) {
            final qty = _cart[item.id] ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QtyControl(
                  qty: qty,
                  onAdd: () {
                    _addToCart(item.id);
                    setLocalState(() {});
                  },
                  onRemove: () {
                    _removeFromCart(item.id);
                    setLocalState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}

// TAMBAHKAN DI PALING BAWAH FILE seat_selection_screen.dart
List<FoodItem> get globalFoodItems => allFoodItems;
