import 'package:flutter/material.dart';

class PaymentMethodSheet extends StatefulWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelected;
  const PaymentMethodSheet({
    super.key,
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  State<PaymentMethodSheet> createState() => PaymentMethodSheetState();
}

class PaymentMethodSheetState extends State<PaymentMethodSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedMethod;
  }

  static const _groups = [
    {
      'label': 'E-Wallet',
      'methods': [
        {'name': 'GoPay',      'icon': Icons.account_balance_wallet_outlined, 'color': Color(0xFF00AED6)},
        {'name': 'OVO',        'icon': Icons.account_balance_wallet_rounded,  'color': Color(0xFF4B0082)},
        {'name': 'Dana',       'icon': Icons.payment_rounded,                  'color': Color(0xFF1976D2)},
        {'name': 'ShopeePay', 'icon': Icons.shopping_bag_outlined,            'color': Color(0xFFEE4D2D)},
      ],
    },
    {
      'label': 'Scan & Pay',
      'methods': [
        {'name': 'QRIS', 'icon': Icons.qr_code_2, 'color': Color(0xFF1A237E)},
      ],
    },
    {
      'label': 'Kartu',
      'methods': [
        {'name': 'Credit / Debit Card', 'icon': Icons.credit_card_rounded, 'color': Color(0xFF1565C0)},
      ],
    },
    {
      'label': 'Transfer Bank',
      'methods': [
        {'name': 'Transfer Bank', 'icon': Icons.account_balance_outlined, 'color': Color(0xFF2E7D32)},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Groups
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groups.map((group) {
                  final label = group['label'] as String;
                  final methods = group['methods'] as List;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: methods.asMap().entries.map((entry) {
                            final i = entry.key;
                            final m = entry.value as Map;
                            final name = m['name'] as String;
                            final color = m['color'] as Color;
                            final icon = m['icon'] as IconData;
                            final isSelected = _selected == name;
                            final isLast = i == methods.length - 1;

                            return InkWell(
                              onTap: () => setState(() => _selected = name),
                              borderRadius: BorderRadius.vertical(
                                top: i == 0 ? const Radius.circular(16) : Radius.zero,
                                bottom: isLast ? const Radius.circular(16) : Radius.zero,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1A237E).withValues(alpha: 0.06)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.vertical(
                                    top: i == 0 ? const Radius.circular(16) : Radius.zero,
                                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    // Icon bulat
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? const Color(0xFF1A237E) : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // Radio custom
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
                                          width: isSelected ? 6 : 2,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Tombol Konfirmasi
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selected == null ? null : () => widget.onSelected(_selected!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  _selected == null ? 'Pilih Metode' : 'Bayar dengan $_selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
