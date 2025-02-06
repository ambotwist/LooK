import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SettingsButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final double iconSize;
  final Color iconBackgroundColor;
  final VoidCallback onPressed;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final Color? iconColor;
  final Color? textColor;

  const SettingsButton({
    super.key,
    required this.title,
    required this.icon,
    required this.iconSize,
    this.iconBackgroundColor = Colors.transparent,
    required this.onPressed,
    this.subtitle,
    this.subtitleStyle,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  subtitle!,
                  style: subtitleStyle ??
                      TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Ionicons.chevron_forward,
                size: 20,
                color: Theme.of(context).colorScheme.scrim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
