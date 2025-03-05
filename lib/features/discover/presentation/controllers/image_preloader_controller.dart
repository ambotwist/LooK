import 'package:flutter/material.dart';
import 'package:lookapp/features/discover/domain/services/image_cache_service.dart';
import 'package:lookapp/test/models/hm_items.dart';

/// Handles preloading and managing of images for cards
class ImagePreloaderController {
  final BuildContext context;
  final Set<String> _loadedImages = {};
  final Map<String, Widget> _preRenderedImages = {};
  bool _didPreloadImages = false;

  // Services
  final _imageCacheService = ImageCacheService();
  final _renderedImageCache = RenderedImageCache();

  ImagePreloaderController(this.context);

  /// Check if an image is loaded
  bool isImageLoaded(String imageUrl) => _loadedImages.contains(imageUrl);

  /// Get a pre-rendered image if available
  Widget? getPreRenderedImage(String imageUrl) => _preRenderedImages[imageUrl];

  /// Clear loaded state for the controller
  void clearLoadedState() {
    _loadedImages.clear();
    _preRenderedImages.clear();
    _didPreloadImages = false;
  }

  /// Preload all images for a specific item
  void preloadItemImages(HMItem item, {int currentIndex = 0}) {
    if (_didPreloadImages) return;

    for (final imageUrl in item.images) {
      // Determine image priority based on current index
      final isCurrentOrNext = imageUrl == item.images[currentIndex] ||
          (currentIndex + 1 < item.images.length &&
              imageUrl == item.images[currentIndex + 1]);

      // Pre-render the image
      _preRenderImage(imageUrl);

      // Precache with appropriate priority
      _imageCacheService.prefetchImage(
        context,
        imageUrl,
        size: isCurrentOrNext ? const Size(1000, 1000) : null,
        onError: (exception, stackTrace) {
          debugPrint('Error precaching image $imageUrl: $exception');
        },
      );
    }

    _didPreloadImages = true;
  }

  /// Preload the next image in sequence
  void preloadNextImage(HMItem item, int currentIndex) {
    if (item.images.length <= 1) return;

    // Calculate the next index
    final nextIndex = (currentIndex + 1) % item.images.length;
    final nextNextIndex = (currentIndex + 2) % item.images.length;

    // Get the URLs
    final nextImageUrl = item.images[nextIndex];
    final nextNextImageUrl = item.images[nextNextIndex];

    // Preload next image with high priority
    _preRenderImage(nextImageUrl);
    _imageCacheService.prefetchImage(
      context,
      nextImageUrl,
      size: const Size(1000, 1000),
      onError: (exception, stackTrace) {
        debugPrint('Error precaching next image $nextImageUrl: $exception');
      },
    );

    // Preload next-next image with normal priority
    _preRenderImage(nextNextImageUrl);
    _imageCacheService.prefetchImage(
      context,
      nextNextImageUrl,
      onError: (exception, stackTrace) {
        debugPrint(
            'Error precaching next-next image $nextNextImageUrl: $exception');
      },
    );
  }

  /// Create or get a pre-rendered image widget
  Widget buildOptimizedImage(String imageUrl, String fallbackImageUrl) {
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
    return _buildImage(imageUrl, fallbackImageUrl);
  }

  /// Mark an image as loaded
  void markImageLoaded(String imageUrl) {
    _loadedImages.add(imageUrl);
  }

  // PRIVATE METHODS

  /// Pre-render an image and store it for immediate use
  void _preRenderImage(String imageUrl) {
    if (_preRenderedImages.containsKey(imageUrl)) return;

    // Check if the image is already in the LRU cache
    if (_renderedImageCache.containsKey(imageUrl)) {
      // Use the cached image
      _preRenderedImages[imageUrl] = _renderedImageCache.get(imageUrl)!;
      // Mark as loaded since it's in the cache
      _loadedImages.add(imageUrl);
      return;
    }

    // Create a new image widget
    final imageProvider = _imageCacheService.getImageProvider(imageUrl);
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

  /// Build a standard image with loading and error handling
  Widget _buildImage(String imageUrl, String fallbackImageUrl) {
    final imageProvider = _imageCacheService.getImageProvider(imageUrl);

    return Image(
      key: ValueKey<String>(imageUrl),
      image: imageProvider,
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
                image: _imageCacheService.getImageProvider(fallbackImageUrl),
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
                image: _imageCacheService.getImageProvider(fallbackImageUrl),
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
        debugPrint('Error loading image $imageUrl: $error');
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
