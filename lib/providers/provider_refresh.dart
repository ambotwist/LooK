import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple provider that can be used to force a refresh of other providers
final refreshProvider = StateProvider<int>((ref) => 0);

/// Helper function to trigger a refresh
void triggerRefresh(WidgetRef ref) {
  ref.read(refreshProvider.notifier).state++;
}
