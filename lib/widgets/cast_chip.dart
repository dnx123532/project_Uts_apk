import 'package:flutter/material.dart';

class CastChip extends StatelessWidget {
  final String name;
  const CastChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 14, color: Color(0xFF1A237E)),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
