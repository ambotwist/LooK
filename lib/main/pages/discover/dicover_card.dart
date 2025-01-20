import 'package:flutter/material.dart';
import 'package:lookapp/models/items.dart';
// import 'package:lookapp/models/item.dart';

class DiscoverCard extends StatefulWidget {
  final Item item;

  const DiscoverCard({
    super.key,
    required this.item,
  });

  @override
  State<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
