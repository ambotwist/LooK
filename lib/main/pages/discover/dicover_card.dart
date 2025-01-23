import 'package:flutter/material.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/models/items.dart';
// import 'package:lookapp/models/item.dart';

class DiscoverCard extends StatefulWidget {
  final Item item;
  final int currentImageIndex;

  const DiscoverCard({
    super.key,
    required this.item,
    this.currentImageIndex = 0,
  });

  @override
  State<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  @override
  void initState() {
    super.initState();
  }

  void handleTapLeft() {
    setState(() {
      // Replace currentImageIndex with widget.currentImageIndex
    });
  }

  void handleTapRight() {
    setState(() {
      // Replace currentImageIndex with widget.currentImageIndex
    });
  }

  Column getInfoColumn(int index) {
    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardIconTextRow(
                icon: Icons.supervisor_account_rounded,
                text: widget.item.gender.displayName),
            CardIconTextRow(
                icon: Icons.straighten_rounded,
                text: widget.item.size.displayName),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardIconTextRow(
                icon: Icons.iron_rounded, text: widget.item.styles.join(', ')),
            CardIconTextRow(
                icon: Icons.balance_rounded,
                text: widget.item.materials.join(', ')),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${widget.item.description}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardIconTextRow(
                icon: Icons.supervisor_account_rounded,
                text: widget.item.gender.displayName),
            CardIconTextRow(
                icon: Icons.straighten_rounded,
                text: widget.item.size.displayName),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Image section
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Item images
                Image(
                  image: NetworkImage(
                      widget.item.images[widget.currentImageIndex]),
                  fit: BoxFit.cover,
                ),
                // Tap area
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: handleTapLeft,
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: handleTapRight,
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image indicators
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 24.0),
                    child: Row(
                      children: List.generate(
                        widget.item.images.length,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: index == widget.currentImageIndex
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Info Section
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 0, 85),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40)),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              icon: Icons.store_rounded,
                              text: widget.item.storeName),
                          const SizedBox(
                            height: 16.0,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.item.price.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(
                          height: 0.0,
                        ),
                        CardIconTextRow(
                          icon: Icons.stars_rounded,
                          text: widget.item.condition.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                getInfoColumn(widget.currentImageIndex),
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
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
  });

  final IconData icon;
  final String text;
  final TextStyle style;

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
          style: style,
        ),
      ],
    );
  }
}
