import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/enums/item_enums.dart';

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
    Item testItem = Item(
        id: 'id',
        name: 'Shoukya',
        brand: 'Hermes',
        storeId: 'Fripereli & Co.',
        size: Size.m,
        highCategory: HighLevelCategory.tops,
        specificCategory: SpecificCategory.blouses,
        styles: [],
        condition: Condition.asNew,
        price: 40,
        images: []);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Stack(
        children: [
          // Current Card
          DiscoverCard(item: testItem)
        ],
      ),
    );
  }
}
