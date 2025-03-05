import 'package:flutter/material.dart';
import 'package:lookapp/features/discover/domain/services/image_cache_service.dart';
import 'package:lookapp/features/discover/data/models/hm_items.dart';

/// Controller for preloading and managing card images in the discover section
class DiscoverCardPreloader {
  final BuildContext context;
  final ImageCacheService _imageCacheService;

  DiscoverCardPreloader(this.context)
      : _imageCacheService = ImageCacheService();

  /// Preload images for current card with high priority
  void preloadCurrentCardImages(HMItem item, int currentImageIndex) {
    if (item.images.isEmpty) return;

    for (int i = 0; i < item.images.length; i++) {
      final imageUrl = item.images[i];
      final isCurrentOrNext = i == currentImageIndex ||
          i == (currentImageIndex + 1) % item.images.length;

      _imageCacheService.prefetchImage(
        context,
        imageUrl,
        size: isCurrentOrNext ? const Size(1000, 1000) : null,
        onError: (exception, stackTrace) {
          debugPrint(
              'Error precaching current card image $imageUrl: $exception');
        },
      );
    }
  }

  /// Preload images for the next card
  void preloadNextCardImages(HMItem nextItem) {
    if (nextItem.images.isEmpty) return;

    for (int i = 0; i < nextItem.images.length; i++) {
      final imageUrl = nextItem.images[i];
      // First image of next card gets higher priority
      final isFirstImage = i == 0;

      _imageCacheService.prefetchImage(
        context,
        imageUrl,
        size: isFirstImage ? const Size(1000, 1000) : null,
        onError: (exception, stackTrace) {
          debugPrint('Error precaching next card image $imageUrl: $exception');
        },
      );
    }
  }

  /// Preload a specific image with high priority
  void preloadSpecificImage(String imageUrl) {
    _imageCacheService.prefetchImage(
      context,
      imageUrl,
      size: const Size(1000, 1000),
      onError: (exception, stackTrace) {
        debugPrint('Error precaching specific image $imageUrl: $exception');
      },
    );
  }

  /// Preload the first image of the card after the next one with lower priority
  void preloadQueuedCardImage(HMItem queuedItem) {
    if (queuedItem.images.isEmpty) return;

    final imageUrl = queuedItem.images[0];
    _imageCacheService.prefetchImage(
      context,
      imageUrl,
      onError: (exception, stackTrace) {
        debugPrint('Error precaching queued card image $imageUrl: $exception');
      },
    );
  }

  /// Preload all relevant images for the current view state
  void preloadAllImages({
    required HMItem currentItem,
    required int currentImageIndex,
    HMItem? nextItem,
    HMItem? queuedItem,
  }) {
    // Preload current card
    preloadCurrentCardImages(currentItem, currentImageIndex);

    // Preload next card if available
    if (nextItem != null) {
      preloadNextCardImages(nextItem);
    }

    // Preload queued card if available
    if (queuedItem != null) {
      preloadQueuedCardImage(queuedItem);
    }
  }

  /// Preload the next image in the sequence for the current card
  void preloadNextImageInSequence(HMItem item, int currentImageIndex) {
    if (item.images.length <= 1) return;

    final nextIndex = (currentImageIndex + 1) % item.images.length;
    final nextImageUrl = item.images[nextIndex];

    preloadSpecificImage(nextImageUrl);
  }
}
