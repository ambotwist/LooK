import 'package:flutter/material.dart';

/// Displays indicators for multiple images in a product card
class ImageIndicators extends StatelessWidget {
  final int imageCount;
  final int currentIndex;
  final EdgeInsets padding;

  const ImageIndicators({
    super.key,
    required this.imageCount,
    required this.currentIndex,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: List.generate(
          imageCount,
          (index) => Expanded(
            child: Container(
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: index == currentIndex
                    ? Colors.white
                    : Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                ),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
