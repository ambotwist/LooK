import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AccountButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final double iconSize;
  final Color iconBackgroundColor;
  const AccountButton({
    super.key,
    required this.title,
    required this.icon,
    required this.iconSize,
    this.iconBackgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
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
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Ionicons.chevron_forward,
                size: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
