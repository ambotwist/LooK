import 'package:flutter/material.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/models/items.dart';

class DiscoverCard extends StatefulWidget {
  final Item item;
  final int currentImageIndex;
  final bool isCurrentCard;

  const DiscoverCard({
    super.key,
    required this.item,
    this.currentImageIndex = 0,
    this.isCurrentCard = false,
  });

  @override
  State<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  final List<ImageProvider> _preloadedImages = [];
  bool _didPreloadImages = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPreloadImages) {
      _preloadImages();
      _didPreloadImages = true;
    }
  }

  @override
  void didUpdateWidget(DiscoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item ||
        oldWidget.isCurrentCard != widget.isCurrentCard) {
      _preloadImages();
      _didPreloadImages = true;
    }
  }

  void _preloadImages() {
    _preloadedImages.clear();

    // For non-current cards, only preload the first image
    final imagesToLoad =
        widget.isCurrentCard ? widget.item.images : [widget.item.images.first];

    for (final imageUrl in imagesToLoad) {
      final imageProvider = NetworkImage(imageUrl);
      _preloadedImages.add(imageProvider);
      // Trigger image preloading
      precacheImage(imageProvider, context);
    }
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
    const infoSectionHeight = 180.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Image section
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Item images
                  Image(
                    image: _preloadedImages.isNotEmpty
                        ? _preloadedImages[
                            widget.currentImageIndex % _preloadedImages.length]
                        : NetworkImage(
                            widget.item.images[widget.currentImageIndex]),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: Icon(Icons.error),
                        ),
                      );
                    },
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
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
        ),
        // Info Section
        Container(
          height: infoSectionHeight,
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
                      child: SizedBox(
                        height: infoSectionHeight / 2.33,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${widget.item.brand} ${widget.item.specificCategory.displayName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
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
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${widget.item.price.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
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
