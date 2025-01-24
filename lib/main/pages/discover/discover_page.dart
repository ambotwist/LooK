import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/providers/interactions_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/main/pages/discover/action_bar.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  final OverlayPortalController overlayPortalController;
  final double navbarHeight;

  const DiscoverPage(
      {super.key,
      required this.overlayPortalController,
      required this.navbarHeight});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with SingleTickerProviderStateMixin {
  Offset dragOffset = Offset.zero;
  late AnimationController slideController;
  Offset? slideOutTween;
  bool isProcessingInteraction = false;

  @override
  void initState() {
    super.initState();
    // Show overlay when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(overlayProvider).show();
      }
    });

    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (slideOutTween != null && slideOutTween != Offset.zero) {
            ref.read(discoverProvider.notifier).nextCard();
            setState(() {
              dragOffset = Offset.zero;
              slideOutTween = null;
              isProcessingInteraction = false;
            });
          } else {
            setState(() {
              dragOffset = Offset.zero;
              slideOutTween = null;
              isProcessingInteraction = false;
            });
          }
          slideController.reset();
          // Show overlay after animation completes
          if (mounted) {
            ref.read(overlayProvider).show();
          }
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show overlay when dependencies change (e.g., when page becomes visible)
    if (mounted) {
      ref.read(overlayProvider).show();
    }
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Hide overlay when page is deactivated (e.g., when navigating away)
    ref.read(overlayProvider).hide();
    super.deactivate();
  }

  @override
  void activate() {
    // Show overlay when page is activated (e.g., when navigating back)
    super.activate();
    if (mounted) {
      ref.read(overlayProvider).show();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (slideController.isAnimating || isProcessingInteraction) return;
    setState(() {
      dragOffset += details.delta;
    });
    // Show overlay during pan
    ref.read(overlayProvider).show();
  }

  void _onPanEnd(DragEndDetails details, Size size) async {
    if (isProcessingInteraction) return;

    final dx = dragOffset.dx;
    final dy = dragOffset.dy;
    if (dx.abs() > size.width * 0.4 || dy.abs() > size.height * 0.4) {
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
      final InteractionStatus status;
      if (dx.abs() > dy.abs()) {
        status = dx > 0 ? InteractionStatus.like : InteractionStatus.dislike;
      } else {
        status = dy > 0
            ? InteractionStatus.badCondition
            : InteractionStatus.tooExpensive;
      }

      setState(() {
        isProcessingInteraction = true;
      });

      try {
        // Update interaction here for swipe gestures
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
          setState(() {
            slideOutTween = Offset(
              dx.abs() > dy.abs()
                  ? (dx > 0 ? size.width * 1.5 : -size.width * 1.5)
                  : 0,
              dy.abs() > dx.abs()
                  ? (dy > 0 ? size.height * 1.5 : -size.height * 1.5)
                  : 0,
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
              error: (error, stackTrace) {
                return Center(
                  child: Text('Error: $error'),
                );
              },
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
              data: (items) {
                if (items.isEmpty ||
                    discoverState.currentIndex >= items.length) {
                  return const Center(
                    child: Text(
                      'No more items to discover',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

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
                            onTapUp: (details) {
                              final cardWidth = size.width;
                              final tapX = details.localPosition.dx;
                              if (tapX < cardWidth / 2) {
                                // Left tap
                                if (items[discoverState.currentIndex]
                                        .images
                                        .length >
                                    1) {
                                  ref
                                      .read(discoverProvider.notifier)
                                      .updateImageIndex(
                                        (discoverState.currentImageIndex -
                                                1 +
                                                items[discoverState
                                                        .currentIndex]
                                                    .images
                                                    .length) %
                                            items[discoverState.currentIndex]
                                                .images
                                                .length,
                                      );
                                }
                              } else {
                                // Right tap
                                if (items[discoverState.currentIndex]
                                        .images
                                        .length >
                                    1) {
                                  ref
                                      .read(discoverProvider.notifier)
                                      .updateImageIndex(
                                        (discoverState.currentImageIndex + 1) %
                                            items[discoverState.currentIndex]
                                                .images
                                                .length,
                                      );
                                }
                              }
                            },
                            child: AnimatedBuilder(
                              animation: slideController,
                              builder: (context, child) {
                                final offset = slideOutTween != null
                                    ? Offset.lerp(
                                        dragOffset,
                                        slideOutTween,
                                        slideOutTween == Offset.zero
                                            ? Curves.easeOutBack.transform(
                                                slideController.value)
                                            : Curves.easeOutQuart.transform(
                                                slideController.value),
                                      )!
                                    : dragOffset;

                                return Transform.translate(
                                  offset: offset,
                                  child: Transform.rotate(
                                    angle: offset.dx / size.width * 0.4 +
                                        offset.dy / size.height * 0.2,
                                    child: Stack(
                                      children: [
                                        DiscoverCard(
                                          item:
                                              items[discoverState.currentIndex],
                                          currentImageIndex:
                                              discoverState.currentImageIndex,
                                          isCurrentCard: true,
                                        ),
                                        // White overlay with animation
                                        AnimatedBuilder(
                                          animation: slideController,
                                          builder: (context, child) {
                                            final overlayOffset =
                                                slideOutTween != null
                                                    ? Offset.lerp(
                                                        dragOffset,
                                                        slideOutTween,
                                                        slideOutTween ==
                                                                Offset.zero
                                                            ? Curves.easeOutBack
                                                                .transform(
                                                                    slideController
                                                                        .value)
                                                            : Curves
                                                                .easeOutQuart
                                                                .transform(
                                                                    slideController
                                                                        .value),
                                                      )!
                                                    : dragOffset;

                                            return Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.white.withOpacity(
                                                    (overlayOffset.distance /
                                                            size.width)
                                                        .clamp(0.0, 0.5),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Like overlay
                                        Positioned(
                                          top: 40,
                                          left: 30,
                                          child: Opacity(
                                            opacity: (dragOffset.dx > 0 &&
                                                    dragOffset.dx.abs() >
                                                        dragOffset.dy.abs())
                                                ? (dragOffset.dx /
                                                        (size.width / 2))
                                                    .clamp(0.0, 1.0)
                                                : 0.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                border: Border.all(
                                                  color: Colors.green,
                                                  width: 4,
                                                ),
                                              ),
                                              child: const Text(
                                                'LIKE',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Nope overlay
                                        Positioned(
                                          top: 40,
                                          right: 30,
                                          child: Opacity(
                                            opacity: (dragOffset.dx < 0 &&
                                                    dragOffset.dx.abs() >
                                                        dragOffset.dy.abs())
                                                ? (-dragOffset.dx /
                                                        (size.width / 2))
                                                    .clamp(0.0, 1.0)
                                                : 0.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                border: Border.all(
                                                  color: Colors.red,
                                                  width: 4,
                                                ),
                                              ),
                                              child: const Text(
                                                'NOPE',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Too Expensive overlay (bottom)
                                        Positioned(
                                          bottom: 30,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Opacity(
                                              opacity: (dragOffset.dy < 0 &&
                                                      dragOffset.dy.abs() >
                                                          dragOffset.dx.abs())
                                                  ? (-dragOffset.dy /
                                                          (size.height / 4))
                                                      .clamp(0.0, 1.0)
                                                  : 0.0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  border: Border.all(
                                                    color: Colors.orange,
                                                    width: 4,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'TOO EXPENSIVE',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Bad Condition overlay (top)
                                        Positioned(
                                          top: 30,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Opacity(
                                              opacity: (dragOffset.dy > 0 &&
                                                      dragOffset.dy.abs() >
                                                          dragOffset.dx.abs())
                                                  ? (dragOffset.dy /
                                                          (size.height / 4))
                                                      .clamp(0.0, 1.0)
                                                  : 0.0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  border: Border.all(
                                                    color: Colors.purple,
                                                    width: 4,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'BAD CONDITION',
                                                  style: TextStyle(
                                                    color: Colors.purple,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (items.isNotEmpty &&
                              discoverState.currentIndex < items.length)
                            OverlayPortal(
                              controller: widget.overlayPortalController,
                              overlayChildBuilder: (BuildContext context) {
                                final bool isDragging =
                                    dragOffset != Offset.zero;
                                const double bigButtonHeight = 42;
                                const double smallButtonHeight = 32;

                                return Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: widget.navbarHeight +
                                      bottomPadding -
                                      bigButtonHeight / 2,
                                  child: ActionBar(
                                    isDragging: isDragging,
                                    dragOffset: dragOffset,
                                    screenWidth: size.width,
                                    bigButtonHeight: bigButtonHeight,
                                    smallButtonHeight: smallButtonHeight,
                                    onDislike: () async {
                                      final currentItem = ref
                                          .read(itemsProvider)
                                          .value![discoverState.currentIndex];
                                      final success = await ref
                                          .read(interactionsProvider.notifier)
                                          .updateInteraction(
                                            currentItem.id,
                                            InteractionStatus.dislike,
                                          );

                                      if (success) {
                                        setState(() {
                                          slideOutTween =
                                              Offset(-size.width * 1.5, 0);
                                          slideController.forward();
                                        });
                                      }
                                    },
                                    onLike: () async {
                                      final currentItem = ref
                                          .read(itemsProvider)
                                          .value![discoverState.currentIndex];
                                      final success = await ref
                                          .read(interactionsProvider.notifier)
                                          .updateInteraction(
                                            currentItem.id,
                                            InteractionStatus.like,
                                          );

                                      if (success) {
                                        setState(() {
                                          slideOutTween =
                                              Offset(size.width * 1.5, 0);
                                          slideController.forward();
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
