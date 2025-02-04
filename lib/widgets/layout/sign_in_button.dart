import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color color;
  final double iconSize;
  final Color textColor;
  final dynamic onPressed;

  const SignInButton(
      {super.key,
      required this.text,
      required this.iconPath,
      required this.color,
      this.iconSize = 32,
      this.textColor = Colors.black,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 48,
        width: 250,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
