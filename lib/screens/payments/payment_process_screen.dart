import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_uts_apk/screens/payments/payment_success_screen.dart';
import '../../models/booking_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../widgets/time_banner.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/card_field.dart';

final BookingState bookingState = BookingState();

// ─── PAYMENT PROCESS SCREEN ───────────────────────────────────────────────────
class PaymentProcessScreen extends StatefulWidget {
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> selectedSeats;
  final int ticketPrice;
  final List<Map<String, dynamic>> foodOrder;
  final String paymentMethod;
  final int grandTotal;

  const PaymentProcessScreen({
    super.key,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.foodOrder,
    required this.paymentMethod,
    required this.grandTotal,
  });

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  int _remainingSeconds = 5 * 60;
  Timer? _timer;
  final _inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputCtrl.dispose();
    super.dispose();
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

  bool get _isQris => widget.paymentMethod == 'QRIS';
  bool get _isCard => widget.paymentMethod == 'Credit/Debit Card';

  void _confirmPaid() {
    _timer?.cancel();

    // Simpan ke booking state
    final booking = BookingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movie: widget.movie,
      cinemaName: widget.cinemaName,
      screenType: widget.screenType,
      time: widget.time,
      date: widget.date,
      seats: widget.selectedSeats,
      ticketPrice: widget.ticketPrice,
      foodOrder: widget.foodOrder,
      paymentMethod: widget.paymentMethod,
      grandTotal: widget.grandTotal,
      bookedAt: DateTime.now(),
    );
    bookingState.addBooking(booking);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PaymentSuccessScreen(booking: booking)),
      (route) => route.isFirst,
    );
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
        title: Text(
          widget.paymentMethod,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          TimerBanner(
            timerText: _timerText,
            remainingSeconds: _remainingSeconds,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF1A237E).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmt(widget.grandTotal),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Konten berdasarkan metode
                  if (_isQris) _buildQris(),
                  if (_isCard) _buildCardInput(),
                  if (!_isQris && !_isCard) _buildGenericPayment(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          BottomActionBar(
            label: 'Konfirmasi Pembayaran',
            enabled: true,
            onTap: _confirmPaid,
          ),
        ],
      ),
    );
  }

  Widget _buildQris() {
    return Column(
      children: [
        const Text(
          'Scan QR Code berikut untuk membayar',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/qris.png', // ✏️ ganti path QRIS kamu
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 220,
                height: 220,
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taruh gambar QRIS di\nassets/images/qris.png',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Berlaku hingga $_timerText',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Buka aplikasi e-wallet kamu dan scan QR di atas',
          style: TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Masukkan detail kartu kamu',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CardField(
          label: 'Nomor Kartu',
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: CardField(
                label: 'Berlaku Hingga',
                hint: 'MM/YY',
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: CardField(
                label: 'CVV',
                hint: '•••',
                keyboardType: TextInputType.number,
                obscure: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const CardField(
          label: 'Nama di Kartu',
          hint: 'JOHN DOE',
          keyboardType: TextInputType.name,
        ),
      ],
    );
  }

  Widget _buildGenericPayment() {
    return Column(
      children: [
        // Icon metode
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.payment_rounded,
            color: Color(0xFF1A237E),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.paymentMethod,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selesaikan pembayaran melalui aplikasi pilihanmu,\nlalu tekan konfirmasi di bawah.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
        ),
        const SizedBox(height: 20),
        // Nomor virtual / kode bayar (simulasi)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Kode Pembayaran',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                _generateCode(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Salin kode ini ke aplikasi kamu',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _generateCode() {
    final hash = widget.grandTotal + widget.cinemaName.hashCode.abs();
    return (hash % 900000 + 100000).toString();
  }
}
