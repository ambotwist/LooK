import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/discover/animations/slide_animation.dart';
import 'package:lookapp/discover/models/items.dart';
import 'package:lookapp/discover/providers/discover_provider.dart';
import 'package:lookapp/discover/providers/interactions_provider.dart';
import 'package:lookapp/discover/providers/item_provider.dart';
import 'package:lookapp/discover/providers/overlay_provider.dart';

class InteractionHandler {
  final WidgetRef ref;
  final SlideAnimation slideAnimation;
  final BuildContext context;
  final Function(VoidCallback) setState;
  final AnimationController slideController;

  InteractionHandler({
    required this.ref,
    required this.slideAnimation,
    required this.context,
    required this.setState,
    required this.slideController,
  });

  void onPanUpdate(DragUpdateDetails details) {
    if (slideController.isAnimating || slideAnimation.isProcessingInteraction)
      return;

    setState(() {
      slideAnimation.updateDragOffset(details);
    });
  }

  Future<void> onPanEnd(DragEndDetails details, Size size) async {
    if (slideAnimation.isProcessingInteraction) return;

    if (slideAnimation.shouldSlideOut(details, size)) {
      final items = ref.read(itemsProvider).asData?.value;
      final currentIndex = ref.read(discoverProvider).currentIndex;

      if (items == null || currentIndex >= items.length) {
        setState(() {
          slideAnimation.cancelSlideOut();
        });
        return;
      }

      final currentItem = items[currentIndex];

      // Determine the interaction status based on horizontal direction only
      final InteractionStatus status = slideAnimation.dragOffset.dx > 0
          ? InteractionStatus.like
          : InteractionStatus.dislike;

      setState(() {
        slideAnimation.isProcessingInteraction = true;
      });

      try {
        final success =
            await ref.read(interactionsProvider.notifier).updateInteraction(
                  currentItem.id,
                  status,
                );

        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to register ${status.name} interaction',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (context.mounted) {
            setState(() {
              slideAnimation.cancelSlideOut();
            });
          }
        } else if (context.mounted) {
          setState(() {
            slideAnimation.prepareSlideOut(
                size, status == InteractionStatus.like);
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            slideAnimation.cancelSlideOut();
          });
        }
      }
    } else {
      setState(() {
        slideAnimation.cancelSlideOut();
      });
    }
    slideAnimation.startAnimation();
  }

  Future<void> handleAction(
    DiscoverState discoverState,
    List<Item> items,
    InteractionStatus status,
    Offset targetOffset,
  ) async {
    final currentItem = items[discoverState.currentIndex];
    final success = await ref
        .read(interactionsProvider.notifier)
        .updateInteraction(currentItem.id, status);

    if (success) {
      setState(() {
        slideAnimation.slideOutTween = targetOffset;
        slideAnimation.isProcessingInteraction = true;
        slideAnimation.startAnimation();
      });
    }
  }

  Future<void> handleRewind() async {
    final discoverNotifier = ref.read(discoverProvider.notifier);
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(itemsProvider).asData?.value;

    if (discoverState.previousIndices.isEmpty || items == null) {
      return;
    }

    try {
      // Get the previous item that we're rewinding to
      final previousIndex = discoverState.previousIndices.last;
      final previousItem = items[previousIndex];

      // Rewind the card immediately for better UX
      discoverNotifier.rewindCard();

      // Show the action bar if it was hidden
      ref.read(overlayProvider).show();

      // Delete the interaction to reset the card's state
      final success =
          await ref.read(interactionsProvider.notifier).updateInteraction(
                previousItem.id,
                null, // Pass null to delete the interaction
              );

      if (!success) {
        _showErrorSnackBar('Failed to reset interaction');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void handleTapUp(
    TapUpDetails details,
    List<Item> items,
    DiscoverState discoverState,
  ) {
    final cardWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;
    final currentItem = items[discoverState.currentIndex];

    if (currentItem.images.length <= 1) return;

    if (tapX < cardWidth / 2) {
      // Left tap - previous image
      final newIndex =
          (discoverState.currentImageIndex - 1 + currentItem.images.length) %
              currentItem.images.length;
      ref.read(discoverProvider.notifier).updateImageIndex(newIndex);
    } else {
      // Right tap - next image
      final newIndex =
          (discoverState.currentImageIndex + 1) % currentItem.images.length;
      ref.read(discoverProvider.notifier).updateImageIndex(newIndex);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
