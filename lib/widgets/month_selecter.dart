import 'package:flutter/material.dart';

class MonthSelecter extends StatelessWidget {
  final String month;
  final bool isActive;

  const MonthSelecter({
    super.key,
    required this.month,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFF5B8FF9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            month,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
