import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/features/discover/presentation/controllers/image_preloader_controller.dart';
import 'package:lookapp/features/discover/presentation/widgets/card_info_section.dart';
import 'package:lookapp/features/discover/presentation/widgets/image_indicators.dart';
import 'package:lookapp/test/models/hm_items.dart';

/// A card displaying product information with images, used in the discover section
class DiscoverCard extends ConsumerStatefulWidget {
  final HMItem item;
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
  late ImagePreloaderController _imageController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageController = ImagePreloaderController(context);
    _imageController.preloadItemImages(widget.item,
        currentIndex: widget.currentImageIndex);
  }

  @override
  void didUpdateWidget(DiscoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the item changed, reset the image controller state
    if (oldWidget.item.id != widget.item.id) {
      _imageController.clearLoadedState();
      _imageController.preloadItemImages(widget.item,
          currentIndex: widget.currentImageIndex);
    }

    // If the image index changed, preload the next image
    if (oldWidget.currentImageIndex != widget.currentImageIndex) {
      _imageController.preloadNextImage(widget.item, widget.currentImageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Image with smooth transitions
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _imageController.buildOptimizedImage(
                        currentImageUrl, previousImageUrl),
                  ),

                  // Image indicators
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ImageIndicators(
                      imageCount: widget.item.images.length,
                      currentIndex: widget.currentImageIndex,
                    ),
                  ),

                  // Info Section
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CardInfoSection(
                      item: widget.item,
                      infoColumnIndex: widget.currentImageIndex,
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
