import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/providers/wishlist_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lookapp/test/models/hm_items.dart';

// Global image cache to persist across card instances
final Map<String, ImageProvider> _globalImageCache = {};

// LRU (Least Recently Used) cache to keep the most recently used images in memory
// This prevents images from being garbage collected
class _LRUCache<K, V> {
  final int capacity;
  final Map<K, V> _cache = {};
  final List<K> _keys = [];

  _LRUCache(this.capacity);

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Move to the end of the list (most recently used)
    _keys.remove(key);
    _keys.add(key);

    return _cache[key];
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing key
      _cache[key] = value;
      _keys.remove(key);
      _keys.add(key);
    } else {
      // Add new key
      if (_keys.length >= capacity) {
        // Remove least recently used
        final lruKey = _keys.removeAt(0);
        _cache.remove(lruKey);
      }
      _cache[key] = value;
      _keys.add(key);
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);
}

// Global LRU cache for rendered images
final _renderedImageCache =
    _LRUCache<String, Image>(50); // Keep 50 images in memory

class HMDiscoverCard extends ConsumerStatefulWidget {
  final HMItem item;
  final int currentImageIndex;
  final bool isCurrentCard;

  const HMDiscoverCard({
    super.key,
    required this.item,
    this.currentImageIndex = 0,
    this.isCurrentCard = false,
  });

  @override
  ConsumerState<HMDiscoverCard> createState() => _HMDiscoverCardState();
}

class _HMDiscoverCardState extends ConsumerState<HMDiscoverCard> {
  bool _didPreloadImages = false;
  // Keep track of which images are fully loaded
  final Set<String> _loadedImages = {};
  // Keep a map of pre-rendered image widgets
  final Map<String, Widget> _preRenderedImages = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPreloadImages) {
      _preloadImages();
      _didPreloadImages = true;
    }
  }

  @override
  void didUpdateWidget(HMDiscoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _preloadImages();
      _loadedImages.clear();
      _preRenderedImages.clear();
    }

    // If the image index changed, ensure the next image is preloaded
    if (oldWidget.currentImageIndex != widget.currentImageIndex) {
      _preloadNextImage();
    }
  }

  void _preloadImages() {
    // Preload all images for the current card with high priority
    for (final imageUrl in widget.item.images) {
      if (!_globalImageCache.containsKey(imageUrl)) {
        final imageProvider = NetworkImage(
          imageUrl,
          // Add caching headers to improve performance
          headers: const {
            'Cache-Control': 'max-age=31536000', // Cache for a year
          },
        );
        _globalImageCache[imageUrl] = imageProvider;

        // Pre-render the image widget
        _preRenderImage(imageUrl, imageProvider);

        // Use a higher priority for the current and next images
        final isCurrentOrNext = imageUrl ==
                widget.item.images[widget.currentImageIndex] ||
            (widget.currentImageIndex + 1 < widget.item.images.length &&
                imageUrl == widget.item.images[widget.currentImageIndex + 1]);

        precacheImage(
          imageProvider,
          context,
          size: isCurrentOrNext
              ? const Size(1000, 1000)
              : null, // Hint for higher resolution if current/next
          onError: (exception, stackTrace) {
            print('Error precaching image $imageUrl: $exception');
          },
        );
      } else {
        // If the image is already in the cache, pre-render it
        _preRenderImage(imageUrl, _globalImageCache[imageUrl]!);
      }
    }
  }

  // Pre-render an image and store it for immediate use
  void _preRenderImage(String imageUrl, ImageProvider imageProvider) {
    if (!_preRenderedImages.containsKey(imageUrl)) {
      // Check if the image is already in the LRU cache
      if (_renderedImageCache.containsKey(imageUrl)) {
        // Use the cached image
        _preRenderedImages[imageUrl] = _renderedImageCache.get(imageUrl)!;
        // Mark as loaded since it's in the cache
        _loadedImages.add(imageUrl);
        return;
      }

      // Create a new image widget
      final imageWidget = Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            // Mark this image as loaded
            _loadedImages.add(imageUrl);
          }
          return child;
        },
      );

      // Store in our local map and the global LRU cache
      _preRenderedImages[imageUrl] = imageWidget;
      _renderedImageCache.put(imageUrl, imageWidget);
    }
  }

  void _preloadNextImage() {
    if (widget.item.images.length <= 1) return;

    // Calculate indices for the next few images to preload
    final nextIndex =
        (widget.currentImageIndex + 1) % widget.item.images.length;
    final nextNextIndex =
        (widget.currentImageIndex + 2) % widget.item.images.length;

    // Preload the next image with high priority
    final nextImageUrl = widget.item.images[nextIndex];
    if (!_globalImageCache.containsKey(nextImageUrl)) {
      final imageProvider = NetworkImage(
        nextImageUrl,
        headers: const {
          'Cache-Control': 'max-age=31536000', // Cache for a year
        },
      );
      _globalImageCache[nextImageUrl] = imageProvider;

      // Pre-render the next image
      _preRenderImage(nextImageUrl, imageProvider);

      precacheImage(
        imageProvider,
        context,
        size: const Size(1000, 1000), // Hint for higher resolution
        onError: (exception, stackTrace) {
          print('Error precaching next image $nextImageUrl: $exception');
        },
      );
    } else {
      // If the image is already in the cache, pre-render it
      _preRenderImage(nextImageUrl, _globalImageCache[nextImageUrl]!);
    }

    // Also preload the image after the next one with normal priority
    final nextNextImageUrl = widget.item.images[nextNextIndex];
    if (!_globalImageCache.containsKey(nextNextImageUrl)) {
      final imageProvider = NetworkImage(
        nextNextImageUrl,
        headers: const {
          'Cache-Control': 'max-age=31536000', // Cache for a year
        },
      );
      _globalImageCache[nextNextImageUrl] = imageProvider;

      // Pre-render the next next image
      _preRenderImage(nextNextImageUrl, imageProvider);

      precacheImage(
        imageProvider,
        context,
        onError: (exception, stackTrace) {
          print(
              'Error precaching next next image $nextNextImageUrl: $exception');
        },
      );
    } else {
      // If the image is already in the cache, pre-render it
      _preRenderImage(nextNextImageUrl, _globalImageCache[nextNextImageUrl]!);
    }
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (!_globalImageCache.containsKey(imageUrl)) {
      // Create a network image with caching enabled
      final imageProvider = NetworkImage(
        imageUrl,
        // Add caching headers to improve performance
        headers: const {
          'Cache-Control': 'max-age=31536000', // Cache for a year
        },
      );

      _globalImageCache[imageUrl] = imageProvider;

      // Pre-render the image
      _preRenderImage(imageUrl, imageProvider);

      // Trigger precaching in the background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        precacheImage(
          imageProvider,
          context,
          onError: (exception, stackTrace) {
            print('Error loading image $imageUrl: $exception');
          },
        );
      });

      return imageProvider;
    }
    return _globalImageCache[imageUrl]!;
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
                if (widget.item.fit != null)
                  CardIconTextRow(
                      icon: Ionicons.resize, text: widget.item.fit!),
                if (widget.item.materials.isNotEmpty)
                  CardIconTextRow(
                      icon: Ionicons.pricetag,
                      text: widget.item.materials.join(', ')),
                if (widget.item.colors.isNotEmpty)
                  CardIconTextRow(
                      icon: Ionicons.color_palette,
                      text: widget.item.colors.join(', ')),
              ],
            ),
          _ => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.styles.isNotEmpty)
                  CardIconTextRow(
                      icon: Ionicons.shirt,
                      text: widget.item.styles.join(', ')),
                if (widget.item.measurements != null)
                  CardIconTextRow(
                      icon: Ionicons.resize,
                      text: widget.item.measurements!.join(', ')),
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

    // Get the current image URL
    final currentImageUrl = widget.item.images[widget.currentImageIndex];

    // Get the previous image URL for fallback
    final previousImageUrl = widget.item.images.length > 1
        ? widget.item.images[
            (widget.currentImageIndex - 1 + widget.item.images.length) %
                widget.item.images.length]
        : currentImageUrl;

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
                  // Item images with AnimatedSwitcher for smooth transitions
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _buildImageWithFallback(
                        currentImageUrl, previousImageUrl),
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
                                    height: infoSectionHeight / 2.2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            widget.item.name ?? 'Unnamed Item',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w600,
                                              height: 1.2,
                                              leadingDistribution:
                                                  TextLeadingDistribution.even,
                                            ),
                                            maxLines: 2,
                                            minFontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          widget.item.brand ?? 'Unknown Brand',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
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

  // Build the image with a fallback for smooth transitions
  Widget _buildImageWithFallback(String imageUrl, String fallbackImageUrl) {
    // Check if we have a pre-rendered image
    if (_preRenderedImages.containsKey(imageUrl)) {
      // If the image is already loaded, use it directly
      if (_loadedImages.contains(imageUrl)) {
        return _preRenderedImages[imageUrl]!;
      }

      // If not loaded yet but we have a fallback that's loaded, show both with a transition
      if (_loadedImages.contains(fallbackImageUrl)) {
        return Stack(
          key: ValueKey<String>(imageUrl),
          children: [
            // Show the fallback image underneath
            _preRenderedImages[fallbackImageUrl]!,

            // Show the target image on top with a fade-in effect
            _preRenderedImages[imageUrl]!,
          ],
        );
      }
    }

    // Fallback to standard image loading if pre-rendered images aren't available
    return Image(
      key: ValueKey<String>(imageUrl),
      image: _getImageProvider(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // If the image was loaded synchronously or the frame is not null (image is ready)
        if (wasSynchronouslyLoaded || frame != null) {
          // Mark this image as loaded
          _loadedImages.add(imageUrl);
          return child;
        }

        // Show the previous image until the new one is loaded
        if (_loadedImages.contains(fallbackImageUrl)) {
          return Stack(
            children: [
              // Show the fallback image
              Image(
                image: _getImageProvider(fallbackImageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Fade in the new image when it's ready
              AnimatedOpacity(
                opacity: frame == null ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
            ],
          );
        }

        // If no fallback is available, just show the child
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        // If the image is loaded, show it
        if (loadingProgress == null) {
          return child;
        }

        // If we have a fallback image that's loaded, show it instead of a loading indicator
        if (_loadedImages.contains(fallbackImageUrl)) {
          return Stack(
            children: [
              Image(
                image: _getImageProvider(fallbackImageUrl),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Only show a loading indicator if the image is taking too long
              if (loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.cumulativeBytesLoaded <
                      loadingProgress.expectedTotalBytes! * 0.8)
                Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
            ],
          );
        }

        // Fallback to standard loading indicator
        return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image $imageUrl: $error');
        return Container(
          color: Colors.white,
          child: const Center(
            child: Icon(Icons.error),
          ),
        );
      },
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
