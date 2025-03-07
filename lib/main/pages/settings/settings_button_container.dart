import 'package:flutter/material.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';

class SettingsButtonContainer extends StatelessWidget {
  final String title;
  final List<SettingsButton> children;
  const SettingsButtonContainer({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ]),
    );
  }
}
