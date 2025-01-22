import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/providers/interactions_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/main/pages/discover/action_bar.dart';

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
  int currentIndex = 0;
  Offset dragOffset = Offset.zero;
  late AnimationController slideController;
  Offset? slideOutTween;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (slideOutTween != null && slideOutTween != Offset.zero) {
            final currentItem = ref.read(itemsProvider).value![currentIndex];

            final status = slideOutTween!.dx > 0
                ? InteractionStatus.like
                : InteractionStatus.dislike;

            ref.read(interactionsProvider.notifier).updateInteraction(
                  currentItem.id,
                  status,
                );

            setState(() {
              currentIndex++;
              dragOffset = Offset.zero;
              slideOutTween = null;
            });
          } else {
            setState(() {
              dragOffset = Offset.zero;
              slideOutTween = null;
            });
          }
          slideController.reset();
        }
      });
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  void _onPanEnd(DragEndDetails details, Size size) async {
    final dx = dragOffset.dx;
    if (dx.abs() > size.width * 0.4) {
      final currentItem = ref.read(itemsProvider).value![currentIndex];

      final status =
          dx > 0 ? InteractionStatus.like : InteractionStatus.dislike;

      final success =
          await ref.read(interactionsProvider.notifier).updateInteraction(
                currentItem.id,
                status,
              );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${status == InteractionStatus.like ? 'like' : 'dislike'} item',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          slideOutTween = Offset.zero;
        });
      } else {
        setState(() {
          slideOutTween = Offset(
            dx > 0 ? size.width * 1.5 : -size.width * 1.5,
            0,
          );
        });
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
    final size = MediaQuery.of(context).size;
    const bottomPadding = 42.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: bottomPadding),
      child: Stack(
        children: [
          items.when(
              error: (error, stackTrace) {
                // print('Error loading items: $error');
                // print('Stack trace: $stackTrace');
                return Center(
                  child: Text('Error: $error'),
                );
              },
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
              data: (items) {
                if (items.isEmpty || currentIndex >= items.length) {
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
                          if (currentIndex + 1 < items.length)
                            DiscoverCard(
                              item: items[currentIndex + 1],
                            ),

                          // Current card (with gestures)
                          GestureDetector(
                            onPanUpdate: (details) {
                              if (slideController.isAnimating) return;
                              setState(() {
                                dragOffset += details.delta;
                              });
                            },
                            onPanEnd: (details) => _onPanEnd(details, size),
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
                                    angle: offset.dx / size.width * 0.4,
                                    child: Stack(
                                      children: [
                                        DiscoverCard(
                                          item: items[currentIndex],
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
                                                    (overlayOffset.dx.abs() /
                                                            (size.width / 2))
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
                                            opacity: (dragOffset.dx > 0)
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
                                        Positioned(
                                          top: 40,
                                          right: 30,
                                          child: Opacity(
                                            opacity: (dragOffset.dx < 0)
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          OverlayPortal(
                            controller: widget.overlayPortalController,
                            overlayChildBuilder: (BuildContext context) {
                              final bool isDragging = dragOffset != Offset.zero;
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
                                  onDislike: () {
                                    // Handle dislike
                                  },
                                  onLike: () {
                                    // Handle like
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
