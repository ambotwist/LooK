import 'package:flutter/material.dart';

class OverlayAnimation {
  Widget buildOverlays(Offset offset, Size size) {
    final dx = offset.dx;
    final baseOpacity = (offset.distance / size.width).clamp(0.0, 0.5);

    // Determine overlay color based on horizontal direction only
    Color overlayColor = dx > 0 ? Colors.green : Colors.red;

    return Stack(
      children: [
        // White overlay base
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(baseOpacity * 0.5),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        // Colored overlay on top
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: overlayColor.withOpacity(baseOpacity * 0.3),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        // Like overlay
        Positioned(
          top: 40,
          left: 30,
          child: Opacity(
            opacity: dx > 0 ? (dx / (size.width / 2)).clamp(0.0, 1.0) : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                border: Border.all(
                  color: Colors.green,
                  width: 4,
                ),
              ),
              child: const Text(
                'LIKE',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Nope overlay
        Positioned(
          top: 40,
          right: 30,
          child: Opacity(
            opacity: dx < 0 ? (-dx / (size.width / 2)).clamp(0.0, 1.0) : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                border: Border.all(
                  color: Colors.red,
                  width: 4,
                ),
              ),
              child: const Text(
                'NOPE',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
