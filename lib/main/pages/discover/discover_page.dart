import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/providers/interactions_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/main/pages/discover/action_bar.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/models/items.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  final double navbarHeight;

  const DiscoverPage({
    super.key,
    required this.navbarHeight,
  });

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with SingleTickerProviderStateMixin {
  Offset dragOffset = Offset.zero;
  late AnimationController slideController;
  Offset? slideOutTween;
  bool isProcessingInteraction = false;
  bool _isDragging = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (slideOutTween != null && slideOutTween != Offset.zero) {
        ref.read(discoverProvider.notifier).nextCard();
      }

      if (mounted) {
        setState(() {
          dragOffset = Offset.zero;
          slideOutTween = null;
          isProcessingInteraction = false;
          _isDragging = false;
        });
      }

      slideController.reset();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (slideController.isAnimating || isProcessingInteraction) return;

    if (!_isDragging) {
      setState(() {
        _isDragging = true;
        dragOffset = details.delta;
      });
    } else {
      setState(() {
        dragOffset += details.delta;
      });
    }
  }

  void _onPanEnd(DragEndDetails details, Size size) async {
    if (isProcessingInteraction) return;

    final dx = dragOffset.dx;
    final dy = dragOffset.dy;
    final velocity = details.velocity;

    // Calculate velocity contribution (pixels that would be traveled in 1 second)
    final projectedDx =
        dx + velocity.pixelsPerSecond.dx * 0.2; // Use 200ms of velocity
    final projectedDy = dy + velocity.pixelsPerSecond.dy * 0.2;

    // Check if either actual position or velocity-adjusted position exceeds threshold
    final positionThreshold = 0.4;
    final velocityThreshold = 1000.0; // pixels per second

    if (dx.abs() > size.width * positionThreshold ||
        dy.abs() > size.height * positionThreshold ||
        velocity.pixelsPerSecond.dx.abs() > velocityThreshold ||
        velocity.pixelsPerSecond.dy.abs() > velocityThreshold) {
      final items = ref.read(itemsProvider).asData?.value;
      final currentIndex = ref.read(discoverProvider).currentIndex;

      if (items == null || currentIndex >= items.length) {
        setState(() {
          slideOutTween = Offset.zero;
        });
        return;
      }

      final currentItem = items[currentIndex];

      // Determine the interaction status based on dominant direction
      // Use projected values for more natural feel with velocity
      final InteractionStatus status;
      if (projectedDx.abs() > projectedDy.abs()) {
        status = projectedDx > 0
            ? InteractionStatus.like
            : InteractionStatus.dislike;
      } else {
        status = projectedDy > 0
            ? InteractionStatus.badCondition
            : InteractionStatus.tooExpensive;
      }

      setState(() {
        isProcessingInteraction = true;
      });

      try {
        final success =
            await ref.read(interactionsProvider.notifier).updateInteraction(
                  currentItem.id,
                  status,
                );

        if (!success && mounted) {
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

          if (mounted) {
            setState(() {
              slideOutTween = Offset.zero;
              isProcessingInteraction = false;
            });
          }
        } else if (mounted) {
          // Calculate the exit velocity and add it to the tween
          final velocityMultiplier =
              0.3; // Adjust this to control velocity influence
          setState(() {
            slideOutTween = Offset(
              projectedDx.abs() > projectedDy.abs()
                  ? (projectedDx > 0 ? size.width * 1.5 : -size.width * 1.5)
                  : velocity.pixelsPerSecond.dx * velocityMultiplier,
              projectedDy.abs() > projectedDx.abs()
                  ? (projectedDy > 0 ? size.height * 1.5 : -size.height * 1.5)
                  : velocity.pixelsPerSecond.dy * velocityMultiplier,
            );
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            slideOutTween = Offset.zero;
            isProcessingInteraction = false;
          });
        }
      }
    } else {
      setState(() {
        slideOutTween = Offset.zero;
      });
    }
    slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);
    final discoverState = ref.watch(discoverProvider);
    final size = MediaQuery.of(context).size;
    const bottomPadding = 36.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: bottomPadding),
      child: Stack(
        children: [
          items.when(
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            data: (items) {
              if (items.isEmpty || discoverState.currentIndex >= items.length) {
                return const Center(
                  child: Text(
                    'No more items to discover',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final animation = CurvedAnimation(
                parent: slideController,
                curve: slideOutTween == Offset.zero
                    ? Curves.easeOutBack
                    : Curves.easeOutQuart,
              );

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Next card (if available)
                        if (discoverState.currentIndex + 1 < items.length)
                          DiscoverCard(
                            item: items[discoverState.currentIndex + 1],
                            isCurrentCard: false,
                          ),

                        // Current card (with gestures)
                        GestureDetector(
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: (details) => _onPanEnd(details, size),
                          onTapUp: (details) =>
                              _handleTapUp(details, items, discoverState),
                          child: ValueListenableBuilder<double>(
                            valueListenable: animation,
                            builder: (context, value, child) {
                              final offset = slideOutTween != null
                                  ? Offset.lerp(
                                      dragOffset, slideOutTween, value)!
                                  : dragOffset;

                              return Transform.translate(
                                offset: offset,
                                child: Transform.rotate(
                                  angle: offset.dx / size.width * 0.4 +
                                      offset.dy / size.height * 0.2,
                                  child: Stack(
                                    children: [
                                      DiscoverCard(
                                        item: items[discoverState.currentIndex],
                                        currentImageIndex:
                                            discoverState.currentImageIndex,
                                        isCurrentCard: true,
                                      ),
                                      if (_isDragging)
                                        _buildOverlays(offset, size),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Action bar overlay
                        _buildActionBar(
                            size, bottomPadding, discoverState, items),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTapUp(
      TapUpDetails details, List<Item> items, DiscoverState discoverState) {
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

  Widget _buildActionBar(Size size, double bottomPadding, dynamic discoverState,
      List<dynamic> items) {
    const double bigButtonHeight = 42;
    const double smallButtonHeight = 32;

    if (_selectedIndex != 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.navbarHeight + bottomPadding - bigButtonHeight / 2,
      child: ActionBar(
        isDragging: _isDragging,
        dragOffset: dragOffset,
        screenWidth: size.width,
        bigButtonHeight: bigButtonHeight,
        smallButtonHeight: smallButtonHeight,
        onDislike: () => _handleAction(
          discoverState,
          items,
          InteractionStatus.dislike,
          Offset(-size.width * 1.5, 0),
        ),
        onLike: () => _handleAction(
          discoverState,
          items,
          InteractionStatus.like,
          Offset(size.width * 1.5, 0),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    dynamic discoverState,
    List<dynamic> items,
    InteractionStatus status,
    Offset targetOffset,
  ) async {
    final currentItem = items[discoverState.currentIndex];
    final success = await ref
        .read(interactionsProvider.notifier)
        .updateInteraction(currentItem.id, status);

    if (success && mounted) {
      setState(() {
        slideOutTween = targetOffset;
        slideController.forward();
      });
    }
  }

  Widget _buildOverlays(Offset offset, Size size) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            (offset.distance / size.width).clamp(0.0, 0.5),
          ),
        ),
      ),
    );
  }
}
