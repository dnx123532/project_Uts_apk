import 'package:flutter/material.dart';

class TimerBanner extends StatelessWidget {
  final String timerText;
  final int remainingSeconds;
  const TimerBanner({
    super.key,
    required this.timerText,
    required this.remainingSeconds,
  });

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
