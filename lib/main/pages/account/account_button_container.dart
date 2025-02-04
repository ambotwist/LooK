import 'package:flutter/material.dart';
import 'package:lookapp/main/pages/account/account_button.dart';

class AccountButtonContainer extends StatelessWidget {
  final String title;
  final List<AccountButton> children;
  const AccountButtonContainer({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            )),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    ]);
  }
}
