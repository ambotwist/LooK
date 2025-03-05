import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/features/discover/data/repositories/item_interaction_repository.dart';
import 'package:lookapp/features/discover/presentation/controllers/discover_card_preloader.dart';
import 'package:lookapp/features/discover/presentation/controllers/swipe_animation_controller.dart';
import 'package:lookapp/features/discover/presentation/animations/discover_animations.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/features/discover/data/models/hm_items.dart';
import 'package:lookapp/features/discover/data/providers/hm_interactions_provider.dart';
import 'package:lookapp/features/discover/data/providers/hm_item_provider.dart';

/// Provider for the ItemInteractionRepository
final itemInteractionRepositoryProvider =
    Provider((ref) => ItemInteractionRepository());

/// Controller that handles user interactions with cards
class CardInteractionController {
  final BuildContext context;
  final WidgetRef ref;
  final AnimationController shakeController;
  final SwipeAnimationController swipeController;
  final DiscoverCardPreloader preloader;

  CardInteractionController({
    required this.context,
    required this.ref,
    required this.shakeController,
    required this.swipeController,
  }) : preloader = DiscoverCardPreloader(context);

  /// Handle tapping on a card to change the image
  void handleTapUp(
      TapUpDetails details, List<HMItem> items, DiscoverState discoverState) {
    final cardWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;
    final currentItem = items[discoverState.currentIndex];

    if (currentItem.images.length <= 1) return;

    int newIndex;
    if (tapX < cardWidth / 2) {
      // Left tap - previous image
      newIndex =
          (discoverState.currentImageIndex - 1 + currentItem.images.length) %
              currentItem.images.length;
    } else {
      // Right tap - next image
      newIndex =
          (discoverState.currentImageIndex + 1) % currentItem.images.length;
    }

    // Update the image index with a small delay to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 50), () {
      ref.read(discoverProvider.notifier).updateImageIndex(newIndex);

      // Preload the next image in the sequence immediately
      preloader.preloadNextImageInSequence(currentItem, newIndex);
    });
  }

  /// Handle the rewind action to go back to previous card
  Future<void> handleRewind() async {
    final discoverNotifier = ref.read(discoverProvider.notifier);
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(hmItemProvider).items;

    if (discoverState.previousIndices.isEmpty || items.isEmpty) {
      // Shake the rewind button to indicate nothing to rewind
      ShakeAnimation.triggerShake(shakeController);
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
      final interactionRepo = ref.read(itemInteractionRepositoryProvider);
      final success = await interactionRepo.updateInteraction(
        previousItem.id,
        null,
      );

      if (!success) {
        _showErrorSnackBar('Failed to reset interaction');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  /// Handle explicit interactions initiated by buttons
  Future<void> handleInteraction(
    HMInteractionStatus status,
    SwipeDirection direction,
  ) async {
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(hmItemProvider).items;

    if (items.isEmpty || discoverState.currentIndex >= items.length) {
      return;
    }

    final currentItem = items[discoverState.currentIndex];
    final interactionRepo = ref.read(itemInteractionRepositoryProvider);

    // Trigger the swipe animation
    swipeController.triggerSwipe(direction, MediaQuery.of(context).size);

    // Update the interaction
    try {
      await interactionRepo.updateInteraction(currentItem.id, status);
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  /// Show an error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Provider for the card interaction controller
final cardInteractionControllerProvider =
    Provider.family<CardInteractionController, BuildContext>(
  (ref, context) {
    // This will be initialized properly in the widget
    throw UnimplementedError(
        'This provider needs to be overridden in the widget');
  },
);
