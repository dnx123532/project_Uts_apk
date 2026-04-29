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
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final m = _methods[i];
              final name = m['name'] as String;
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
