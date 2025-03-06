import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/discover/animations/card_animation.dart';
import 'package:lookapp/discover/animations/overlay_animation.dart';
import 'package:lookapp/discover/animations/slide_animation.dart';
import 'package:lookapp/discover/dicover_card.dart';
import 'package:lookapp/discover/models/items.dart';
import 'package:lookapp/discover/providers/discover_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

class CardStack extends ConsumerWidget {
  final List<Item> items;
  final DiscoverState discoverState;
  final SlideAnimation slideAnimation;
  final OverlayAnimation overlayAnimation;
  final CardAnimation cardAnimation;
  final AnimationController slideController;
  final Function(TapUpDetails, List<Item>, DiscoverState) onTapUp;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails, Size) onPanEnd;

  const CardStack({
    Key? key,
    required this.items,
    required this.discoverState,
    required this.slideAnimation,
    required this.overlayAnimation,
    required this.cardAnimation,
    required this.slideController,
    required this.onTapUp,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty || discoverState.currentIndex >= items.length) {
      return const Center(
        child: Text(
          'No more items to discover',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final animation = CurvedAnimation(
      parent: slideController,
      curve: slideAnimation.slideOutTween == Offset.zero
          ? Curves.easeOutBack
          : Curves.easeOutQuart,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background card (next card)
            if (discoverState.currentIndex + 1 < items.length)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return cardAnimation.buildBackgroundCard(
                      child: child!,
                      isDragging: slideAnimation.isDragging,
                      isAnimating: slideController.isAnimating,
                      animation: animation,
                    );
                  },
                  child: DiscoverCard(
                    item: items[discoverState.currentIndex + 1],
                    isCurrentCard: false,
                  ),
                ),
              ),
            // Top card (current card)
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: onPanUpdate,
                onPanEnd: (details) => onPanEnd(details, size),
                onTapUp: (details) => onTapUp(details, items, discoverState),
                child: ValueListenableBuilder<double>(
                  valueListenable: animation,
                  builder: (context, value, child) {
                    final offset = slideAnimation.getAnimatedOffset(value);
                    return Transform(
                      transform: cardAnimation.buildCardTransform(offset, size),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          DiscoverCard(
                            item: items[discoverState.currentIndex],
                            currentImageIndex: discoverState.currentImageIndex,
                            isCurrentCard: true,
                          ),
                          if (slideAnimation.isDragging)
                            overlayAnimation.buildOverlays(offset, size),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
