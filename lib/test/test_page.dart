import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/widgets/layout/no_connection_screen.dart';
import 'package:lookapp/providers/connection_provider.dart';

class TestPage extends ConsumerWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionProvider);

    // If there's no internet connection, show the no connection screen
    if (!isConnected) {
      return const NoConnectionScreen();
    }

    return const Center(child: Text('Test'));
  }
}
