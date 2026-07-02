import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_uts_apk/screens/payments/payment_process_screen.dart';
import 'package:project_uts_apk/widgets/app_image.dart';
import 'package:project_uts_apk/widgets/bottom_action_bar.dart';
import 'package:project_uts_apk/widgets/payment_method_sheet.dart';
import 'package:project_uts_apk/widgets/summary_row.dart';
import '../../widgets/icon_text_row.dart';
import '../../widgets/time_banner.dart';

// ─── ORDER SUMMARY SCREEN ─────────────────────────────────────────────────────
class OrderSummaryScreen extends StatefulWidget {
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> selectedSeats;
  final int ticketPrice;
  final List<Map<String, dynamic>> foodOrder;

  const OrderSummaryScreen({
    super.key,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.foodOrder,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  // Countdown 5 menit
  int _remainingSeconds = 5 * 60;
  Timer? _timer;
  String? _selectedPayment;

  static const int _serviceFee = 3500;

  // Promo
  final _promoCtrl = TextEditingController();
  String? _promoCode;
  int _promoDiscount = 0;
  String? _promoError;

  static const _validPromos = {
    'TIXIO10':  {'label': 'Diskon 10%',       'type': 'pct',   'value': 10},
    'HEMAT20':  {'label': 'Diskon 20%',        'type': 'pct',   'value': 20},
    'NEWUSER':  {'label': 'Potongan Rp 15.000','type': 'flat',  'value': 15000},
    'STUDENT':  {'label': 'Potongan Rp 10.000','type': 'flat',  'value': 10000},
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
    final promo = _validPromos[code];
    if (promo == null) {
      setState(() { _promoCode = null; _promoDiscount = 0; _promoError = 'Kode promo tidak valid'; });
      return;
    }
    final base = _ticketSubtotal + _foodSubtotal + _serviceFee;
    final type = promo['type'] as String;
    final value = promo['value'] as int;
    int discount = type == 'pct' ? (base * value ~/ 100) : value;
    final maxDiscount = base - 1000;
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmt(int p) {
    final s = p.toString();
    if (s.length <= 3) return 'Rp $s';
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _fmtDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]}, $dd.$mm.${d.year}';
  }

  int get _ticketSubtotal => widget.selectedSeats.length * widget.ticketPrice;

  int get _foodSubtotal {
    int t = 0;
    for (final f in widget.foodOrder) {
      t += (f['price'] as int) * (f['qty'] as int);
    }
    return t;
  }

  int get _grandTotal {
    final raw = _ticketSubtotal + _foodSubtotal + _serviceFee - _promoDiscount;
    return raw < 0 ? 0 : raw;
  }

  void _openPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  void _confirmPayment() {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran dulu!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _timer?.cancel();

    // Navigasi ke halaman pembayaran sesuai metode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessScreen(
          movie: widget.movie,
          cinemaName: widget.cinemaName,
          screenType: widget.screenType,
          time: widget.time,
          date: widget.date,
          selectedSeats: widget.selectedSeats,
          ticketPrice: widget.ticketPrice,
          foodOrder: widget.foodOrder,
          paymentMethod: _selectedPayment!,
          grandTotal: _grandTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String title = (movie.title ?? '') as String;
    final String imagePath = (movie.imagePath ?? '') as String;

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
          'Ringkasan Order',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Timer banner
          TimerBanner(
            timerText: _timerText,
            remainingSeconds: _remainingSeconds,
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Info film
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        AppImage(
                          path: imagePath,
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
                          errorWidget: Container(
                            width: 90,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              InfoRow2(
                                icon: Icons.location_on_outlined,
                                text: widget.cinemaName,
                              ),
                              const SizedBox(height: 6),
                              InfoRow2(
                                icon: Icons.confirmation_number_outlined,
                                text:
                                    '${widget.screenType.split(' ').first}, CINEMA${_getCinemaNum()}',
                              ),
                              const SizedBox(height: 6),
                              InfoRow2(
                                icon: Icons.calendar_today_outlined,
                                text:
                                    '${_fmtDate(widget.date)} - ${widget.time}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),

                  // Ringkasan Pembayaran
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ringkasan Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kursi
                  SummaryRow(
                    label: '${widget.selectedSeats.length} Tiket',
                    value: widget.selectedSeats.join(', '),
                    isGrey: true,
                  ),
                  SummaryRow(
                    label: 'Harga Tiket',
                    value:
                        '${_fmt(widget.ticketPrice)} x ${widget.selectedSeats.length}',
                    isGrey: true,
                  ),

                  // F&B jika ada
                  if (widget.foodOrder.isNotEmpty)
                    ...widget.foodOrder.map(
                      (f) => SummaryRow(
                        label: '${f['name']} x${f['qty']}',
                        value: _fmt((f['price'] as int) * (f['qty'] as int)),
                        isGrey: true,
                      ),
                    ),

                  SummaryRow(
                    label: 'Sub Total',
                    value: _fmt(_ticketSubtotal + _foodSubtotal),
                    isGrey: true,
                  ),
                  SummaryRow(
                    label: 'Biaya Layanan',
                    value: _fmt(_serviceFee),
                    isGrey: true,
                  ),
                  // Diskon promo jika ada
                  if (_promoDiscount > 0)
                    SummaryRow(
                      label: 'Promo $_promoCode',
                      value: '- ${_fmt(_promoDiscount)}',
                      isGrey: false,
                      isBold: false,
                      valueColor: Colors.green,
                    ),
                  SummaryRow(
                    label: 'Total Pembayaran',
                    value: _fmt(_grandTotal),
                    isGrey: false,
                    isBold: true,
                  ),

                  const SizedBox(height: 16),

                  // Notif refund
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tiket yang dibeli tidak dapat diubah atau di refund.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Promo Code Input ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kode Promo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text(
                          'Coba: TIXIO10 · HEMAT20 · NEWUSER · STUDENT',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Metode Pembayaran ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
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
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Tombol lanjutkan
          BottomActionBar(
            label: 'Lanjutkan Pembayaran',
            enabled: _selectedPayment != null,
            onTap: _confirmPayment,
          ),
        ],
      ),
    );
  }

  String _getCinemaNum() {
    final hash = widget.cinemaName.length + widget.time.hashCode.abs() % 10;
    return '0${(hash % 9) + 1}';
  }
}
