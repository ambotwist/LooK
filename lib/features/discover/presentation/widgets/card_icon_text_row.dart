import 'package:flutter/material.dart';

/// A simple widget that displays an icon and text in a row
class CardIconTextRow extends StatelessWidget {
  const CardIconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    this.iconSize = 20,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          text,
          style: style,
        ),
      ],
    );
  }
}
