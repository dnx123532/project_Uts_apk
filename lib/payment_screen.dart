import 'dart:async';
import 'package:flutter/material.dart';

// ─── BOOKING STATE (global singleton)
// Menyimpan semua histori booking + notifikasi

class BookingItem {
  final String id;
  final dynamic movie;
  final String cinemaName;
  final String screenType;
  final String time;
  final DateTime date;
  final List<String> seats;
  final int ticketPrice;
  final List<Map<String, dynamic>> foodOrder;
  final String paymentMethod;
  final int grandTotal;
  final DateTime bookedAt;

  BookingItem({
    required this.id,
    required this.movie,
    required this.cinemaName,
    required this.screenType,
    required this.time,
    required this.date,
    required this.seats,
    required this.ticketPrice,
    required this.foodOrder,
    required this.paymentMethod,
    required this.grandTotal,
    required this.bookedAt,
  });
}

class BookingState extends ChangeNotifier {
  final List<BookingItem> _bookings = [];
  final List<String> _notifications = [];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);
  List<String> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  // Di dalam class BookingState
  void addBooking(BookingItem item) {
    _bookings.insert(0, item);

    // Logic Notif Pintar: Cek apakah beli tiket atau cuma makanan
    String message = item.seats.isEmpty
        ? 'Pesanan F&B berhasil! Yuk ambil di counter snack.'
        : 'Pemesanan berhasil! ${item.movie.title} - ${item.seats.join(', ')}';

    _notifications.insert(0, message);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

final BookingState bookingState = BookingState();

// ─── ORDER SUMMARY SCREEN
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

  // Biaya layanan tetap
  static const int _serviceFee = 3500;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    return '${days[d.weekday - 1]}, $dd.${mm}.${d.year}';
  }

  int get _ticketSubtotal => widget.selectedSeats.length * widget.ticketPrice;

  int get _foodSubtotal {
    int t = 0;
    for (final f in widget.foodOrder) {
      t += (f['price'] as int) * (f['qty'] as int);
    }
    return t;
  }

  int get _grandTotal => _ticketSubtotal + _foodSubtotal + _serviceFee;

  void _openPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PaymentMethodSheet(
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
          _TimerBanner(
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            imagePath,
                            width: 90,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.movie,
                                color: Colors.grey,
                              ),
                            ),
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
                              _InfoRow2(
                                icon: Icons.location_on_outlined,
                                text: widget.cinemaName,
                              ),
                              const SizedBox(height: 6),
                              _InfoRow2(
                                icon: Icons.confirmation_number_outlined,
                                text:
                                    '${widget.screenType.split(' ').first}, CINEMA${_getCinemaNum()}',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow2(
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
                  _SummaryRow(
                    label: '${widget.selectedSeats.length} Tiket',
                    value: widget.selectedSeats.join(', '),
                    isGrey: true,
                  ),
                  _SummaryRow(
                    label: 'Harga Tiket',
                    value:
                        '${_fmt(widget.ticketPrice)} x ${widget.selectedSeats.length}',
                    isGrey: true,
                  ),

                  // F&B jika ada
                  if (widget.foodOrder.isNotEmpty)
                    ...widget.foodOrder.map(
                      (f) => _SummaryRow(
                        label: '${f['name']} x${f['qty']}',
                        value: _fmt((f['price'] as int) * (f['qty'] as int)),
                        isGrey: true,
                      ),
                    ),

                  _SummaryRow(
                    label: 'Sub Total',
                    value: _fmt(_ticketSubtotal + _foodSubtotal),
                    isGrey: true,
                  ),
                  _SummaryRow(
                    label: 'Biaya Layanan',
                    value: _fmt(_serviceFee),
                    isGrey: true,
                  ),
                  _SummaryRow(
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
                      color: const Color(0xFF1A237E).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tiket yang dibeli tidak dapat diubah atau di refund.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Promo/Voucher
                  ListTile(
                    onTap: () {},
                    title: const Text(
                      'Promo/Voucher',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Kamu belum memilih promo',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Metode pembayaran
                  ListTile(
                    onTap: _openPaymentMethod,
                    title: const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    subtitle: Text(
                      _selectedPayment == null
                          ? _fmt(_grandTotal)
                          : '$_selectedPayment  •  ${_fmt(_grandTotal)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Tombol lanjutkan
          _BottomActionBar(
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

// ─── PAYMENT PROCESS SCREEN
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
  bool _paid = false;

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
          _TimerBanner(
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
          _BottomActionBar(
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
              errorBuilder: (_, __, ___) => Container(
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
        _CardField(
          label: 'Nomor Kartu',
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: _CardField(
                label: 'Berlaku Hingga',
                hint: 'MM/YY',
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _CardField(
                label: 'CVV',
                hint: '•••',
                keyboardType: TextInputType.number,
                obscure: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _CardField(
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

// ─── PAYMENT SUCCESS SCREEN
class PaymentSuccessScreen extends StatelessWidget {
  final BookingItem booking;
  const PaymentSuccessScreen({super.key, required this.booking});

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
    return '${days[d.weekday - 1]}, $dd.${mm}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String title = (booking.movie.title ?? '') as String;
    final String imagePath = (booking.movie.imagePath ?? '') as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Animasi sukses
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tiket kamu sudah dikonfirmasi',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Tiket card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header tiket
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A237E),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    imagePath,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 80,
                                      color: Colors.white24,
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        booking.cinemaName,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Garis putus-putus
                          _DashedDivider(),

                          // Detail tiket
                          // Detail tiket (TIMPA KODE PADDING INI BG)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // TANGGAL TETAP MUNCUL UNTUK SEMUA PESANAN
                                _TicketRow(
                                  label: 'Tanggal',
                                  value: _fmtDate(booking.date),
                                ),

                                // LOGIC PINTAR: INFO INI HANYA MUNCUL JIKA ADA TIKET FILM (KURSI TIDAK KOSONG)
                                if (booking.seats.isNotEmpty) ...[
                                  _TicketRow(label: 'Jam', value: booking.time),
                                  _TicketRow(
                                    label: 'Studio',
                                    value:
                                        '${booking.screenType.split(' ').first}',
                                  ),
                                  _TicketRow(
                                    label: 'Kursi',
                                    value: booking.seats.join(', '),
                                  ),
                                ],

                                // F&B SELALU MUNCUL JIKA ADA PESANAN MAKANAN
                                if (booking.foodOrder.isNotEmpty)
                                  _TicketRow(
                                    label: 'F&B',
                                    value: booking.foodOrder
                                        .map((f) => '${f['name']} x${f['qty']}')
                                        .join(', '),
                                  ),

                                const Divider(height: 20),
                                _TicketRow(
                                  label: 'Metode Bayar',
                                  value: booking.paymentMethod,
                                ),
                                _TicketRow(
                                  label: 'Total',
                                  value: _fmt(booking.grandTotal),
                                  valueStyle: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Tombol ke home
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOOKING HISTORY PAGE
// Ganti BookingPage di tixio_app.dart dengan ini
class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  String _fmtDate(DateTime d) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${days[d.weekday - 1]}, $dd/$mm/${d.year}';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bookingState,
      builder: (context, _) {
        final bookings = bookingState.bookings;

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 64,
                  color: const Color(0xFF1A237E).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tiket Saya',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Belum ada tiket yang dipesan',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Tiket Saya',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final String title = (b.movie.title ?? '') as String;
                  final String imagePath = (b.movie.imagePath ?? '') as String;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailScreen(booking: b),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Poster
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14),
                            ),
                            child: Image.asset(
                              imagePath,
                              width: 90,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    b.cinemaName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // --- INI LOGIC PINTARNYA BG ---
                                  Text(
                                    b.seats.isEmpty
                                        ? '${_fmtDate(b.date)}  •  Pesanan F&B'
                                        : '${_fmtDate(b.date)}  •  ${b.time}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  // ------------------------------
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'Berhasil',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _fmt(b.grandTotal),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

//  BOOKING DETAIL SCREEN
class BookingDetailScreen extends StatelessWidget {
  final BookingItem booking;
  const BookingDetailScreen({super.key, required this.booking});

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
    return '${days[d.weekday - 1]}, $dd.${mm}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String title = (booking.movie.title ?? '') as String;
    final String imagePath = (booking.movie.imagePath ?? '') as String;
    final int ticketTotal = booking.seats.length * booking.ticketPrice;
    int foodTotal = 0;
    for (final f in booking.foodOrder) {
      foodTotal += (f['price'] as int) * (f['qty'] as int);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Film info card
            _WhiteCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 110,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
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
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        _InfoRow2(
                          icon: Icons.theaters_outlined,
                          text: booking.cinemaName,
                        ),

                        // --- LOGIC F&B ---
                        if (booking.seats.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          _InfoRow2(
                            icon: Icons.confirmation_number_outlined,
                            text: booking.screenType,
                          ),
                          const SizedBox(height: 5),
                          _InfoRow2(
                            icon: Icons.calendar_today_outlined,
                            text: '${_fmtDate(booking.date)} • ${booking.time}',
                          ),
                          const SizedBox(height: 5),
                          _InfoRow2(
                            icon: Icons.event_seat_outlined,
                            text: 'Kursi: ${booking.seats.join(', ')}',
                          ),
                        ] else ...[
                          // Kalau cuma F&B, tampilkan tanggal saja
                          const SizedBox(height: 5),
                          _InfoRow2(
                            icon: Icons.calendar_today_outlined,
                            text: '${_fmtDate(booking.date)} • Pesanan F&B',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // F&B jika ada
            if (booking.foodOrder.isNotEmpty)
              _WhiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food & Beverages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...booking.foodOrder.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fastfood_rounded,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${f['name']} x${f['qty']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              _fmt((f['price'] as int) * (f['qty'] as int)),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (booking.foodOrder.isNotEmpty) const SizedBox(height: 14),

            // Ringkasan pembayaran
            // Ringkasan pembayaran
            _WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  // Harga tiket hanya muncul kalau beneran beli tiket
                  if (booking.seats.isNotEmpty)
                    _TicketRow(
                      label: '${booking.seats.length} Tiket',
                      value: _fmt(ticketTotal),
                    ),

                  if (foodTotal > 0)
                    _TicketRow(label: 'F&B', value: _fmt(foodTotal)),

                  // Biaya layanan untuk tiket
                  if (booking.seats.isNotEmpty)
                    const _TicketRow(label: 'Biaya Layanan', value: 'Rp 3,500'),

                  const Divider(height: 16),
                  _TicketRow(
                    label: 'Total Pembayaran',
                    value: _fmt(booking.grandTotal),
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TicketRow(
                    label: 'Metode Bayar',
                    value: booking.paymentMethod,
                  ),
                  const _TicketRow(
                    label: 'Status',
                    value: 'Berhasil',
                    valueStyle: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

//  HELPER WIDGETS

class _TimerBanner extends StatelessWidget {
  final String timerText;
  final int remainingSeconds;
  const _TimerBanner({required this.timerText, required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final isUrgent = remainingSeconds < 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFFFCE4EC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Waiting for Payment  ',
            style: TextStyle(fontSize: 14, color: Colors.pink.shade300),
          ),
          Text(
            timerText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : const Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _BottomActionBar({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodSheet extends StatefulWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelected;
  const _PaymentMethodSheet({
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedMethod;
  }

  static const List<Map<String, dynamic>> _methods = [
    {
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFF00AED6),
    },
    {
      'name': 'ShopeePay',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFFEE4D2D),
    },
    {'name': 'QRIS', 'icon': Icons.qr_code_2, 'color': Color(0xFF1A237E)},
    {
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF1565C0),
    },
    {
      'name': 'Transfer Bank',
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF2E7D32),
    },
    {
      'name': 'OVO',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF4B0082),
    },
    {'name': 'Dana', 'icon': Icons.payment_rounded, 'color': Color(0xFF1976D2)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _methods.length,
            // TIMPA BAGIAN INI BG (Hilangkan Divider, ganti jadi jarak kosong aja)
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final m = _methods[i];
              final name = m['name'] as String;
              final isSelected = _selected == name;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (m['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    m['icon'] as IconData,
                    color: m['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Radio<String>(
                  value: name,
                  groupValue: _selected,
                  activeColor: const Color(0xFF1A237E),
                  onChanged: (v) => setState(() => _selected = v),
                ),
                onTap: () => setState(() => _selected = name),
              );
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => widget.onSelected(_selected!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGrey;
  final bool isBold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isGrey = true,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isGrey ? Colors.grey : Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF1A237E) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _TicketRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style:
                  valueStyle ??
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow2 extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow2({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (_, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();
          return Row(
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                margin: const EdgeInsets.only(right: dashSpace),
                color: Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;
  const _CardField({
    required this.label,
    required this.hint,
    required this.keyboardType,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
