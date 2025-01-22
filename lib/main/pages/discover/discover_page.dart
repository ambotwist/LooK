import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/providers/item_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  int currentIndex = 0;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Stack(
        children: [
          items.when(
            data: (itemsList) {
              if (itemsList.isEmpty) {
                return const Center(child: Text('No items found'));
              }
              return DiscoverCard(item: itemsList[currentIndex]);
            },
            error: (error, stackTrace) {
              // print('Error loading items: $error');
              // print('Stack trace: $stackTrace');
              return Center(
                child: Text('Error: $error'),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
