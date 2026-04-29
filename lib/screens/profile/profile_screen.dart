// PROFILE SCREEN - halaman penuh dengan Scaffold sendiri
import 'package:flutter/material.dart';
import 'package:flutter_application_for_us/data/data_film.dart';
import 'package:flutter_application_for_us/screens/login/login_screen.dart';
import 'package:flutter_application_for_us/screens/payments/payment_process_screen.dart';
import 'package:flutter_application_for_us/widgets/menu.dart';
import 'package:flutter_application_for_us/widgets/section_label.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: AnimatedBuilder(
        animation: authState,
        builder: (context, _) {
          if (!authState.isLoggedIn) {
            // Jika user logout dari dalam halaman ini, pop otomatis
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }
          return _ProfileBody();
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: authState.username);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF1A237E),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A237E),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: authState.email),
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    authState.login(
                      nameCtrl.text.trim(),
                      authState.email ?? '',
                    );
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara memesan tiket?',
        'a':
            'Pilih film, pilih jadwal dan kursi, lalu lakukan pembayaran. Tiket akan dikirim ke email kamu.',
      },
      {
        'q': 'Apakah tiket bisa dibatalkan?',
        'a':
            'Tiket dapat dibatalkan maksimal 2 jam sebelum jadwal tayang. Pengembalian dana diproses dalam 3-5 hari kerja.',
      },
      {
        'q': 'Metode pembayaran apa saja yang tersedia?',
        'a':
            'Kami menerima transfer bank, e-wallet (GoPay, OVO, Dana), kartu kredit/debit, dan QRIS.',
      },
      {
        'q': 'Bagaimana cara menggunakan kode promo?',
        'a':
            'Masukkan kode promo pada halaman pembayaran di kolom yang tersedia sebelum konfirmasi.',
      },
      {
        'q': 'Tiket saya tidak muncul, apa yang harus dilakukan?',
        'a':
            'Cek email kamu atau hubungi CS kami di cs@tixio.id dengan menyertakan bukti pembayaran.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
                'FAQ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: faqs.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) => ExpansionTile(
                    iconColor: const Color(0xFF1A237E),
                    collapsedIconColor: Colors.grey,
                    title: Text(
                      faqs[i]['q']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: Text(
                          faqs[i]['a']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRiwayatPembelian(BuildContext context) {
    // Helper untuk format harga
    String fmtPrice(int p) {
      final s = p.toString();
      if (s.length <= 3) return 'Rp $s';
      final buf = StringBuffer('Rp ');
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        // BUNGKUS PAKAI ANIMATED BUILDER
        builder: (_, scrollCtrl) => AnimatedBuilder(
          animation: bookingState,
          builder: (context, _) {
            // AMBIL DATA ASLI DARI STATE
            final riwayat = bookingState.bookings;

            return Column(
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
                  'Riwayat Pembelian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  // KONDISI JIKA KOSONG
                  child: riwayat.isEmpty
                      ? const Center(
                          child: Text(
                            'Kamu belum pernah membeli tiket.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: riwayat.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            // AMBIL ITEM PER BARIS
                            final item = riwayat[i];
                            final title = (item.movie.title ?? '') as String;

                            // Format Tanggal
                            final d = item.date;
                            final dateStr =
                                '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

                            return Container(
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
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
                                          'Berhasil', // Status hardcode sukses
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _RiwayatRow(
                                    icon: Icons.calendar_today_outlined,
                                    text: '$dateStr • ${item.time}',
                                  ),
                                  const SizedBox(height: 4),
                                  _RiwayatRow(
                                    icon: Icons.theaters_outlined,
                                    text: item.cinemaName,
                                  ),
                                  const SizedBox(height: 4),
                                  _RiwayatRow(
                                    icon: Icons.event_seat_outlined,
                                    text: 'Kursi ${item.seats.join(', ')}',
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        fmtPrice(item.grandTotal),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFilmFavorit(BuildContext context) {
    final favorit = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Column(
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
              'Film Favorit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favorit.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final film = favorit[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        film['imagePath']!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 50,
                          height: 70,
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          child: const Icon(
                            Icons.movie_outlined,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      film['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          film['genre']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              film['rating']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.pink,
                      ),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHubungiCS(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Supaya modal bisa fleksibel tingginya
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        // Tambahkan padding bawah mengikuti keyboard jika muncul
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Penting agar modal tidak kosong ke bawah
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Hubungi Customer Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tim CS kami siap membantu kamu 24/7',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // List pilihan CS
            _CSOption(
              icon: Icons.chat_bubble_outline_rounded,
              color: Colors.green,
              title: 'WhatsApp',
              subtitle: '+62 812-3456-7890',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.email_outlined,
              color: const Color(0xFF1A237E),
              title: 'Email',
              subtitle: 'cs@tixio.id',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.phone_outlined,
              color: Colors.orange,
              title: 'Telepon',
              subtitle: '1500-123 (Senin–Jumat, 08.00–17.00)',
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
            _CSOption(
              icon: Icons.chat_outlined,
              color: Colors.purple,
              title: 'Live Chat',
              subtitle: 'Chat langsung di aplikasi',
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showKebijakanPrivasi(BuildContext context) {
    final kebijakan = [
      {
        'judul': '1. Data yang Kami Kumpulkan',
        'isi':
            'Kami mengumpulkan informasi yang kamu berikan saat mendaftar, seperti nama, email, dan nomor telepon. Kami juga mengumpulkan data transaksi pembelian tiket.',
      },
      {
        'judul': '2. Penggunaan Data',
        'isi':
            'Data kamu digunakan untuk memproses transaksi, mengirimkan konfirmasi tiket, dan meningkatkan layanan kami. Kami tidak menjual data pribadi kamu kepada pihak ketiga.',
      },
      {
        'judul': '3. Keamanan Data',
        'isi':
            'Kami menggunakan enkripsi SSL/TLS untuk melindungi data kamu. Semua informasi pembayaran diproses melalui gateway yang tersertifikasi PCI-DSS.',
      },
      {
        'judul': '4. Cookies',
        'isi':
            'Aplikasi kami menggunakan cookies untuk meningkatkan pengalaman pengguna dan menganalisis trafik. Kamu dapat menonaktifkan cookies melalui pengaturan perangkat.',
      },
      {
        'judul': '5. Hak Kamu',
        'isi':
            'Kamu berhak mengakses, memperbarui, atau menghapus data pribadi kamu kapan saja. Hubungi cs@tixio.id untuk permintaan terkait data.',
      },
      {
        'judul': '6. Perubahan Kebijakan',
        'isi':
            'Kami dapat memperbarui kebijakan privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui email atau notifikasi aplikasi.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Column(
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
              'Kebijakan Privasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                'Terakhir diperbarui: 1 Januari 2025',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: kebijakan.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kebijakan[i]['judul']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kebijakan[i]['isi']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun Tixio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              authState.logout();
              Navigator.pop(ctx); // tutup dialog
              Navigator.pop(context); // kembali ke Home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = authState.username ?? '';
    final email = authState.email ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CustomScrollView(
      slivers: [
        // APP BAR dengan header profil
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFF1A237E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profil Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // BODY ISI
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // SEKSI AKUN
                SectionLabel('Akun'),
                MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF1A237E),
                      label: 'Edit Profil',
                      onTap: () => _showEditProfile(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.confirmation_number_outlined,
                      iconColor: Colors.orange,
                      label: 'Riwayat Pembelian',
                      onTap: () => _showRiwayatPembelian(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.favorite_border_rounded,
                      iconColor: Colors.pink,
                      label: 'Film Favorit',
                      onTap: () => _showFilmFavorit(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SEKSI BANTUAN
                SectionLabel('Bantuan'),
                MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.purple,
                      label: 'FAQ',
                      onTap: () => _showFAQ(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.headset_mic_outlined,
                      iconColor: Colors.green,
                      label: 'Hubungi CS',
                      onTap: () => _showHubungiCS(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.policy_outlined,
                      iconColor: Colors.indigo,
                      label: 'Kebijakan Privasi',
                      onTap: () => _showKebijakanPrivasi(context),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.blueGrey,
                      label: 'Tentang Tixio',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Tixio',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(
                          Icons.movie_filter_rounded,
                          color: Color(0xFF1A237E),
                          size: 48,
                        ),
                        children: const [
                          Text(
                            'Tixio adalah aplikasi pembelian tiket bioskop yang mudah, cepat, dan terpercaya.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, indent: 56, color: Colors.grey.shade100);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    Widget? trailing,
  }) : trailing =
           trailing ??
           const Icon(Icons.chevron_right, color: Colors.grey, size: 20);

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    trailing: trailing,
  );
}

// PROFILE PAGE - tab wrapper (tetap ada untuk bottom nav)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        if (!authState.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Belum Masuk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk melihat profil kamu',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk / Daftar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        // Sudah login: tampilkan isi profil langsung (embedded, tanpa AppBar)
        return _ProfileBody();
      },
    );
  }
}

// RIWAYAT ROW HELPER
class _RiwayatRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RiwayatRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );
}

// CS OPTION HELPER
class _CSOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CSOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            // Bungkus Column dengan Expanded agar sisa space dihitung benar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    // Teks ini sekarang akan otomatis turun ke bawah jika kepanjangan
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
