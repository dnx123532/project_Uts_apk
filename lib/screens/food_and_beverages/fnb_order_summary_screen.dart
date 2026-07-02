import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_uts_apk/data/data_film.dart';
import 'package:project_uts_apk/models/movie_models.dart';
import 'package:project_uts_apk/providers/food_provider.dart';
import 'package:provider/provider.dart';
import 'package:project_uts_apk/screens/payments/payment_process_screen.dart';
import 'package:project_uts_apk/widgets/payment_method_sheet.dart';

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
  int _remainingSeconds = 5 * 60;
  Timer? _timer;

  // Promo
  final _promoCtrl = TextEditingController();
  String? _promoCode;
  int _promoDiscount = 0;
  String? _promoError;

  static const _validPromos = {
    'TIXIO10': {'label': 'Diskon 10%',        'type': 'pct',  'value': 10},
    'HEMAT20': {'label': 'Diskon 20%',         'type': 'pct',  'value': 20},
    'NEWUSER': {'label': 'Potongan Rp 15.000', 'type': 'flat', 'value': 15000},
    'STUDENT': {'label': 'Potongan Rp 10.000', 'type': 'flat', 'value': 10000},
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _promoCtrl.dispose();
    super.dispose();
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _grandTotal {
    final raw = widget.total - _promoDiscount;
    return raw < 0 ? 0 : raw;
  }

  String _fmt(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
    final promo = _validPromos[code];
    if (promo == null) {
      setState(() { _promoCode = null; _promoDiscount = 0; _promoError = 'Kode promo tidak valid'; });
      return;
    }
    final type = promo['type'] as String;
    final value = promo['value'] as int;
    int discount = type == 'pct' ? (widget.total * value ~/ 100) : value;
    final maxDiscount = widget.total - 1000;
    if (discount > maxDiscount) discount = maxDiscount > 0 ? maxDiscount : 0;
    if (discount < 0) discount = 0;
    setState(() {
      _promoCode = code;
      _promoDiscount = discount;
      _promoError = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _removePromo() {
    setState(() { _promoCode = null; _promoDiscount = 0; _promoError = null; _promoCtrl.clear(); });
  }

  void _openPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentMethodSheet(
        selectedMethod: _selectedPayment,
        onSelected: (method) {
          setState(() => _selectedPayment = method);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodItems = context.read<FoodProvider>().foodItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ringkasan Order F&B',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Timer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: _remainingSeconds < 60 ? Colors.red.shade50 : const Color(0xFFFCE4EC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color: _remainingSeconds < 60 ? Colors.red : Colors.redAccent),
                const SizedBox(width: 6),
                Text('Selesaikan pembayaran dalam  ',
                    style: TextStyle(
                        fontSize: 13,
                        color: _remainingSeconds < 60 ? Colors.red : Colors.redAccent)),
                Text(_timerText,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _remainingSeconds < 60 ? Colors.red : Colors.red)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF1A237E), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lokasi Pengambilan',
                                  style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('${widget.cinemaName}, ${locationState.selectedCity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Pesanan F&B',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // List item F&B
                  ...widget.cart.entries.map((e) {
                    final item = foodItems.firstWhere((f) => f.id == e.key);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(item.imagePath,
                                width: 56, height: 56, fit: BoxFit.cover,
                                errorBuilder: (_, e, s) => Container(
                                    width: 56, height: 56,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.fastfood, color: Colors.grey))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('x ${e.value}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(_fmt(item.price * e.value),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                                  color: Color(0xFF1A237E))),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Ringkasan harga
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryLine('Subtotal F&B', _fmt(widget.total)),
                        const SizedBox(height: 6),
                        _SummaryLine('Biaya Layanan', 'Rp 0'),
                        if (_promoDiscount > 0) ...[
                          const SizedBox(height: 6),
                          _SummaryLine('Promo $_promoCode', '- ${_fmt(_promoDiscount)}',
                              valueColor: Colors.green),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _SummaryLine('Total Pembayaran', _fmt(_grandTotal), isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notif refund
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Pesanan yang dibeli tidak dapat diubah atau di refund.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Promo Code ────────────────────────────────────────
                  const Text('Kode Promo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Coba: TIXIO10 · HEMAT20 · NEWUSER · STUDENT',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoCtrl,
                          textCapitalization: TextCapitalization.characters,
                          enabled: _promoCode == null,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kode promo',
                            hintStyle: const TextStyle(fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                            ),
                            errorText: _promoError,
                            filled: _promoCode != null,
                            fillColor: Colors.green.withValues(alpha: 0.06),
                            suffixIcon: _promoCode != null
                                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _promoCode != null
                          ? OutlinedButton(
                              onPressed: _removePromo,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Hapus'),
                            )
                          : ElevatedButton(
                              onPressed: _applyPromo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Pakai', style: TextStyle(color: Colors.white)),
                            ),
                    ],
                  ),
                  if (_promoCode != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${_validPromos[_promoCode]!['label']} berhasil diterapkan!',
                          style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Metode Pembayaran ─────────────────────────────────
                  GestureDetector(
                    onTap: _openPaymentMethod,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedPayment != null
                              ? const Color(0xFF1A237E).withValues(alpha: 0.4)
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.payment_rounded, color: Color(0xFF1A237E), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Metode Pembayaran',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedPayment ?? 'Belum dipilih',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedPayment != null ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: _selectedPayment != null ? const Color(0xFF1A237E) : Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Tombol Bawah
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(_fmt(_grandTotal),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E))),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedPayment == null
                        ? null
                        : () {
                            _timer?.cancel();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentProcessScreen(
                                  movie: const MovieModel(
                                    title: 'Pesanan F&B',
                                    genre: 'Snack & Drink',
                                    imagePath: 'assets/images/Popcorn_Large.png',
                                  ),
                                  cinemaName: widget.cinemaName,
                                  screenType: 'F&B Pick-up',
                                  time: '-',
                                  date: DateTime.now(),
                                  selectedSeats: const [],
                                  ticketPrice: 0,
                                  foodOrder: widget.cart.entries.map((e) {
                                    final item = context.read<FoodProvider>().foodItems
                                        .firstWhere((f) => f.id == e.key);
                                    return {'name': item.name, 'qty': e.value, 'price': item.price};
                                  }).toList(),
                                  paymentMethod: _selectedPayment!,
                                  grandTotal: _grandTotal,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Lanjutkan Pembayaran',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryLine(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: isBold ? 14 : 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 15 : 13,
                color: valueColor ?? (isBold ? const Color(0xFF1A237E) : Colors.black87))),
      ],
    );
  }
}
