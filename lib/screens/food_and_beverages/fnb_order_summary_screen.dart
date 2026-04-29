// ─── F&B ORDER SUMMARY SCREEN ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/data/data_film.dart';
import 'package:flutter_application_for_us/models/movie_models.dart';
import 'package:flutter_application_for_us/screens/food_and_beverages/food_and_beverage_screen.dart';
import 'package:flutter_application_for_us/screens/payments/payment_process_screen.dart';

class FnBOrderSummaryScreen extends StatefulWidget {
  final String cinemaName;
  final Map<String, int> cart;
  final int total;
  const FnBOrderSummaryScreen({
    super.key,
    required this.cinemaName,
    required this.cart,
    required this.total,
  });

  @override
  State<FnBOrderSummaryScreen> createState() => _FnBOrderSummaryScreenState();
}

class _FnBOrderSummaryScreenState extends State<FnBOrderSummaryScreen> {
  String? _selectedPayment;

  // Fungsi Helper
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

  void _openPaymentMethod() {
    // Pakai Modal sederhana biar ga nyenggol file payment_screen.dart
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['GoPay', 'ShopeePay', 'QRIS', 'Transfer Bank'].map(
              (method) => ListTile(
                title: Text(method),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() => _selectedPayment = method);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ringkasan Order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Banner Merah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFFFCE4EC),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Waiting for Payment  ',
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  '19:59',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Bioskop',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${widget.cinemaName}, ${locationState.selectedCity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Food & Beverages',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // List Makanan
                  ...widget.cart.entries.map((e) {
                    final item = globalFoodItems.firstWhere(
                      (f) => f.id == e.key,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'x ${e.value}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatPrice(item.price)} x ${e.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 30),
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total F&B',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatPrice(widget.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya Layanan(FnB)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Rp 0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatPrice(widget.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pesanan yang dibeli tidak dapat diubah atau di refund.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(height: 30),

                  // Promo & Bayar
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Promo/Voucher',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Kamu belum memilih promo'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _openPaymentMethod,
                    title: const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      _selectedPayment ?? _formatPrice(widget.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Bawah
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
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedPayment == null
                    ? null
                    : () {
                        // KITA LANGSUNG KIRIM KE PAYMENT PROCESS SCREEN (Bawaan payment_screen.dart)
                        // Supaya Riwayat, Notif, Lonceng otomatis masuk
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentProcessScreen(
                              movie: const MovieModel(
                                title: 'Pesanan F&B',
                                genre: 'Snack & Drink',
                                imagePath: 'assets/images/Popcorn_Large.png',
                              ), // Movie bayangan buat F&B
                              cinemaName: widget.cinemaName,
                              screenType: 'F&B Pick-up',
                              time: '-',
                              date: DateTime.now(),
                              selectedSeats: const [], // Kursi kosong
                              ticketPrice: 0,
                              foodOrder: widget.cart.entries.map((e) {
                                final item = globalFoodItems.firstWhere(
                                  (f) => f.id == e.key,
                                );
                                return {
                                  'name': item.name,
                                  'qty': e.value,
                                  'price': item.price,
                                };
                              }).toList(),
                              paymentMethod: _selectedPayment!,
                              grandTotal: widget.total,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
