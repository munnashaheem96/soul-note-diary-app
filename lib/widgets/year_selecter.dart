import 'package:flutter/material.dart';

class YearSelecter extends StatelessWidget {
  final int year;
  final bool isActive;

  const YearSelecter({
    super.key,
    required this.year,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.35,
      child: Container(
        width: 200,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF5B8FF9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 12,
              bottom: 0,
              child: Text(
                year.toString().substring(2), // 26, 25, 24
                style: TextStyle(
                  color: const Color(0xFF3F6EEB)
                      .withOpacity(isActive ? 1 : 0.4),
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  height: 0.8,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year.toString(), // 2026
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(isActive ? 1 : 0.5),
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'Memories',
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(isActive ? 0.9 : 0.4),
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
