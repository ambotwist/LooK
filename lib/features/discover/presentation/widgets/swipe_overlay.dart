import 'package:flutter/material.dart';
import 'package:lookapp/features/discover/presentation/controllers/swipe_animation_controller.dart';

/// Displays visual overlays when swiping cards
class SwipeOverlay extends StatelessWidget {
  final Offset offset;
  final Size size;

  const SwipeOverlay({
    super.key,
    required this.offset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final dx = offset.dx;
    final dy = offset.dy;
    final baseOpacity = (offset.distance / size.width).clamp(0.0, 0.5);

    // Determine overlay color based on swipe direction
    Color overlayColor;
    if (dy < -20) {
      // Upward swipe - superlike (blue)
      overlayColor = Colors.blue;
    } else {
      // Horizontal swipe - like (green) or dislike (red)
      overlayColor = dx > 0 ? Colors.green : Colors.red;
    }

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
            opacity: dx > 0 && dy.abs() < 20
                ? (dx / (size.width / 2)).clamp(0.0, 1.0)
                : 0.0,
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
            opacity: dx < 0 && dy.abs() < 20
                ? (-dx / (size.width / 2)).clamp(0.0, 1.0)
                : 0.0,
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
        // Superlike overlay
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity:
                  dy < -20 ? (-dy / (size.height / 3)).clamp(0.0, 1.0) : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(
                    color: Colors.blue,
                    width: 4,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'SUPER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
