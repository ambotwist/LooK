import 'package:flutter/material.dart';
import 'package:lookapp/enums/item_enums.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Image section
        // Info Section
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 0, 85),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40)),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.item.brand} ${widget.item.specificCategory.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      CardIconTextRow(
                          icon: Icons.store_rounded, text: widget.item.storeId),
                      const SizedBox(
                        height: 32.0,
                      ),
                      CardIconTextRow(
                          icon: Icons.shape_line_rounded,
                          text:
                              '${widget.item.gender.name}/${widget.item.size.name}')
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '\$${widget.item.price.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardIconTextRow extends StatelessWidget {
  const CardIconTextRow({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
