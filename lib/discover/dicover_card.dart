import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/discover/models/items.dart';
import 'package:lookapp/providers/wishlist_provider.dart';

class DiscoverCard extends ConsumerStatefulWidget {
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
  ConsumerState<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends ConsumerState<DiscoverCard> {
  final Map<String, ImageProvider> _imageCache = {};
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
    if (oldWidget.item != widget.item) {
      _preloadImages();
    }
  }

  void _preloadImages() {
    // Preload all images for both current and next cards
    for (final imageUrl in widget.item.images) {
      if (!_imageCache.containsKey(imageUrl)) {
        final imageProvider = NetworkImage(imageUrl);
        _imageCache[imageUrl] = imageProvider;
        precacheImage(imageProvider, context);
      }
    }
  }

  ImageProvider _getImageProvider(String imageUrl) {
    return _imageCache[imageUrl] ?? NetworkImage(imageUrl);
  }

  Row getInfoColumn(int index) {
    final wishlistState = ref.watch(wishlistProvider);
    final isInWishlist = wishlistState.value?.contains(widget.item.id) ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        switch (index) {
          0 => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardIconTextRow(
                    icon: Ionicons.shirt, text: widget.item.styles.join(', ')),
                CardIconTextRow(
                    icon: Ionicons.pricetag,
                    text: widget.item.materials.join(', ')),
              ],
              //   ),
              // 1 => Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       CardIconTextRow(
              //           icon: Icons.iron_rounded,
              //           text: widget.item.styles.join(', ')),
              //       CardIconTextRow(
              //           icon: Icons.balance_rounded,
              //           text: widget.item.materials.join(', ')),
              //     ],
              //   ),
              // 2 => Expanded(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           '"${widget.item.description}"',
              //           style: const TextStyle(
              //             color: Colors.white,
              //             fontSize: 18,
              //             fontWeight: FontWeight.w500,
              //             fontStyle: FontStyle.italic,
              //           ),
              //         ),
              //       ],
              //     ),
            ),
          _ => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardIconTextRow(
                    icon: Ionicons.shirt, text: widget.item.styles.join(', ')),
                CardIconTextRow(
                    icon: Ionicons.pricetag,
                    text: widget.item.materials.join(', ')),
              ],
            ),
        },
        // Favorite button
        SizedBox(
          height: 52,
          width: 52,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 42,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isInWishlist ? Ionicons.bookmark : Ionicons.bookmark_outline,
                key: ValueKey<bool>(isInWishlist),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            onPressed: () async {
              final success = await ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(widget.item.id);

              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update wishlist'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const infoSectionHeight = 160.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Image section
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  // Item images
                  Image(
                    image: _getImageProvider(
                      widget.item.images[widget.currentImageIndex],
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    gaplessPlayback:
                        true, // Prevent flickering during image changes
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
                              height: 5,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                color: index == widget.currentImageIndex
                                    ? Colors.white
                                    : Colors.black.withOpacity(0.4),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.7)),
                                borderRadius: BorderRadius.circular(1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Info Section
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: infoSectionHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.1, 0.15, 0.5, 0.7, 1.0],
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(1.0),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 16.0, right: 16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: infoSectionHeight / 2.33,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.item.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w600,
                                              height: 1.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Text(
                                          widget.item.brand,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
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
                                      '\$${widget.item.price % 1 == 0 ? widget.item.price.round() : widget.item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            getInfoColumn(widget.currentImageIndex),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    this.iconSize = 20,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: iconSize,
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
