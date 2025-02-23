import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/providers/connection_provider.dart';

class SaveButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String text;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.text = 'Save',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionProvider);

    return TextButton(
      onPressed: isConnected ? onPressed : null,
      style: TextButton.styleFrom(
        disabledBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isConnected ? Colors.blue : Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
