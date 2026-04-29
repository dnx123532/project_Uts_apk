import 'package:flutter/material.dart';

// ─── QTY CONTROL WIDGET ────────────────────────────────────────────────────────
class QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool compact;

  const QtyControl({
    super.key,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 30 : 34;
    final double fontSize = compact ? 14 : 16;

    if (qty == 0) {
      // Hanya tampilkan tombol +
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add, color: Colors.white, size: fontSize),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove, color: Colors.white, size: fontSize),
          ),
        ),
        SizedBox(
          width: compact ? 28 : 32,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.white, size: fontSize),
          ),
        ),
      ],
    );
  }
}
