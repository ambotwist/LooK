import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/main/pages/discover/action_bar.dart';
import 'package:lookapp/main/pages/fliter/filter_page.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/test/models/hm_items.dart';
import 'package:lookapp/test/pages/discover/hm_discover_card.dart';
import 'package:lookapp/test/providers/hm_item_provider.dart';
import 'package:lookapp/test/providers/hm_interactions_provider.dart';
import 'package:lookapp/widgets/layout/filter_dropdown.dart';
import 'package:lookapp/widgets/layout/no_connection_screen.dart';
import 'package:lookapp/providers/connection_provider.dart';
import 'package:lookapp/widgets/layout/search_bar.dart';

class TestDiscoverPage extends ConsumerStatefulWidget {
  final double navbarHeight;

  const TestDiscoverPage({
    super.key,
    required this.navbarHeight,
  });

  @override
  ConsumerState<TestDiscoverPage> createState() => _TestDiscoverPageState();
}

class _TestDiscoverPageState extends ConsumerState<TestDiscoverPage>
    with TickerProviderStateMixin {
  Offset dragOffset = Offset.zero;
  late AnimationController slideController;
  Offset? slideOutTween;
  bool isProcessingInteraction = false;
  bool _isDragging = false;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Preload next card images when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadNextCardImages();
    });
  }

  void _preloadNextCardImages() {
    final itemState = ref.read(hmItemProvider);
    final discoverState = ref.read(discoverProvider);

    if (itemState.items.isEmpty) return;

    // Preload current card with high priority
    if (discoverState.currentIndex < itemState.items.length) {
      final currentItem = itemState.items[discoverState.currentIndex];
      for (int i = 0; i < currentItem.images.length; i++) {
        final imageUrl = currentItem.images[i];
        final isCurrentOrNext = i == discoverState.currentImageIndex ||
            i ==
                (discoverState.currentImageIndex + 1) %
                    currentItem.images.length;

        // Use higher priority for current and next image
        final imageProvider = NetworkImage(
          imageUrl,
          headers: const {
            'Cache-Control': 'max-age=31536000', // Cache for a year
          },
        );

        precacheImage(
          imageProvider,
          context,
          size: isCurrentOrNext
              ? const Size(1000, 1000)
              : null, // Hint for higher resolution if current/next
          onError: (exception, stackTrace) {
            print('Error precaching current card image $imageUrl: $exception');
          },
        );
      }
    }

    // Preload next card
    if (discoverState.currentIndex + 1 < itemState.items.length) {
      final nextItem = itemState.items[discoverState.currentIndex + 1];
      for (int i = 0; i < nextItem.images.length; i++) {
        final imageUrl = nextItem.images[i];
        // First image of next card gets higher priority
        final isFirstImage = i == 0;

        final imageProvider = NetworkImage(
          imageUrl,
          headers: const {
            'Cache-Control': 'max-age=31536000', // Cache for a year
          },
        );

        precacheImage(
          imageProvider,
          context,
          size: isFirstImage
              ? const Size(1000, 1000)
              : null, // Hint for higher resolution if first image
          onError: (exception, stackTrace) {
            print('Error precaching next card image $imageUrl: $exception');
          },
        );
      }
    }

    // Also preload the card after the next one, but with lower priority
    if (discoverState.currentIndex + 2 < itemState.items.length) {
      final nextNextItem = itemState.items[discoverState.currentIndex + 2];
      // Only preload the first image of the card after next
      if (nextNextItem.images.isNotEmpty) {
        final imageUrl = nextNextItem.images[0];
        final imageProvider = NetworkImage(imageUrl);
        precacheImage(
          imageProvider,
          context,
          onError: (exception, stackTrace) {
            print(
                'Error precaching next next card image $imageUrl: $exception');
          },
        );
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (slideOutTween != null && slideOutTween != Offset.zero) {
        ref.read(discoverProvider.notifier).nextCard();

        // Preload next card images after transition
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _preloadNextCardImages();
        });
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

    // Check if either actual position or velocity-adjusted position exceeds threshold
    const positionThreshold = 0.4;
    const velocityThreshold = 1000.0; // pixels per second

    // Check for horizontal swipe (like/dislike)
    final isHorizontalSwipe = dx.abs() > size.width * positionThreshold ||
        velocity.pixelsPerSecond.dx.abs() > velocityThreshold;

    // Check for upward swipe (superlike)
    final isUpwardSwipe = dy < -size.height * 0.3 ||
        velocity.pixelsPerSecond.dy < -velocityThreshold;

    if (isHorizontalSwipe || isUpwardSwipe) {
      final items = ref.read(hmItemProvider).items;
      final currentIndex = ref.read(discoverProvider).currentIndex;

      if (items.isEmpty || currentIndex >= items.length) {
        setState(() {
          slideOutTween = Offset.zero;
        });
        return;
      }

      final currentItem = items[currentIndex];

      // Determine the interaction status based on swipe direction
      HMInteractionStatus status;
      if (isUpwardSwipe) {
        status = HMInteractionStatus.superlike;
      } else {
        status =
            dx > 0 ? HMInteractionStatus.like : HMInteractionStatus.dislike;
      }

      setState(() {
        isProcessingInteraction = true;
      });

      try {
        final success =
            await ref.read(hmInteractionsProvider.notifier).updateInteraction(
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
          const velocityMultiplier =
              0.3; // Adjust this to control velocity influence

          setState(() {
            if (isUpwardSwipe) {
              // For superlike, slide up and out
              slideOutTween = Offset(
                0,
                -size.height * 1.5,
              );
            } else {
              // For like/dislike, slide horizontally
              slideOutTween = Offset(
                dx > 0 ? size.width * 1.5 : -size.width * 1.5,
                velocity.pixelsPerSecond.dy * velocityMultiplier,
              );
            }
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

  void _handleRewind() async {
    final discoverNotifier = ref.read(discoverProvider.notifier);
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(hmItemProvider).items;

    if (discoverState.previousIndices.isEmpty || items.isEmpty) {
      _shakeController.forward().then((_) => _shakeController.reset());
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
          await ref.read(hmInteractionsProvider.notifier).updateInteraction(
                previousItem.id,
                null,
              );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset interaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      toolbarHeight: 42,
      actions: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shakeValue = sin(_shakeController.value * pi * 8);
            return Transform.rotate(
              angle: shakeValue * 0.1,
              child: child,
            );
          },
          child: IconButton(
            icon: const Icon(Ionicons.arrow_undo, size: 28),
            onPressed: _handleRewind,
          ),
        ),
        Expanded(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: const CustomSearchBar(
                  hintText: 'What are you looking for?',
                ))),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              Ionicons.bag,
              size: 26,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(connectionProvider);
    final itemState = ref.watch(hmItemProvider);
    final discoverState = ref.watch(discoverProvider);
    final size = MediaQuery.of(context).size;
    const bottomPadding = 36.0;

    // If there's no internet connection, show the no connection screen
    if (!isConnected) {
      return const NoConnectionScreen();
    }

    // Check if we need to load more items - trigger earlier (10 items before the end)
    // and add a safety check to ensure we're not at the end already
    if (!itemState.isLoading &&
        itemState.hasMore &&
        itemState.items.isNotEmpty &&
        discoverState.currentIndex >= itemState.items.length - 10) {
      print(
          'Approaching end of items, loading more... Current index: ${discoverState.currentIndex}, Total items: ${itemState.items.length}');
      // Load more items when we're 10 or fewer items away from the end
      ref.read(hmItemProvider.notifier).loadMore();
    }

    return Stack(
      children: [
        Column(
          children: [
            _buildAppBar(),
            Container(
              height: 48,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Ionicons.filter_outline),
                    color: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterPage(
                            onApplyFilters: (newFilters) {
                              ref.read(filterProvider.notifier).updateFilters(
                                    seasons: newFilters.seasons,
                                    topSizes: newFilters.topSizes,
                                    shoeSizes: newFilters.shoeSizes,
                                    bottomSizes: newFilters.bottomSizes,
                                    highCategories: newFilters.highCategories,
                                    specificCategories:
                                        newFilters.specificCategories,
                                    colors: newFilters.colors,
                                    priceRange: newFilters.priceRange,
                                    styles: newFilters.styles,
                                  );
                              ref.invalidate(hmItemProvider);
                              ref.read(discoverProvider.notifier).updateState(
                                currentIndex: 0,
                                currentImageIndex: 0,
                                previousIndices: [],
                              );
                              ref.read(overlayProvider).show();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  // Brand Filter Dropdown
                  FilterDropdown(
                    label: 'Brand',
                    selectedValues: ref
                        .watch(filterProvider)
                        .highCategories
                        .where((cat) => ['nike', 'adidas'].contains(cat))
                        .toSet(),
                    items: const [
                      PopupMenuItem(
                        value: 'nike',
                        child: Text('Nike'),
                      ),
                      PopupMenuItem(
                        value: 'adidas',
                        child: Text('Adidas'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value.isEmpty) {
                        // Reset brand filters
                        ref.read(filterProvider.notifier).updateFilters(
                              highCategories: ref
                                  .read(filterProvider)
                                  .highCategories
                                  .where((cat) =>
                                      !['nike', 'adidas'].contains(cat))
                                  .toList(),
                            );
                      } else {
                        ref
                            .read(filterProvider.notifier)
                            .toggleHighCategory(value);
                      }
                      ref.invalidate(hmItemProvider);
                      ref.read(discoverProvider.notifier).updateState(
                        currentIndex: 0,
                        currentImageIndex: 0,
                        previousIndices: [],
                      );
                      ref.read(overlayProvider).show();
                    },
                  ),
                  const SizedBox(width: 8),
                  // Category Filter Dropdown
                  FilterDropdown(
                    label: 'Category',
                    selectedValues: ref
                        .watch(filterProvider)
                        .highCategories
                        .where((cat) => !['nike', 'adidas'].contains(cat))
                        .toSet(),
                    items: Categories.highLevel
                        .where((cat) => !['nike', 'adidas'].contains(cat))
                        .map((category) => PopupMenuItem(
                              value: category,
                              child: Text(categoryToDisplayName(category)),
                            ))
                        .toList(),
                    onSelected: (value) {
                      if (value.isEmpty) {
                        // Reset category filters
                        ref.read(filterProvider.notifier).updateFilters(
                              highCategories: ref
                                  .read(filterProvider)
                                  .highCategories
                                  .where(
                                      (cat) => ['nike', 'adidas'].contains(cat))
                                  .toList(),
                            );
                      } else {
                        ref
                            .read(filterProvider.notifier)
                            .toggleHighCategory(value);
                      }
                      ref.invalidate(hmItemProvider);
                      ref.read(discoverProvider.notifier).updateState(
                        currentIndex: 0,
                        currentImageIndex: 0,
                        previousIndices: [],
                      );
                      ref.read(overlayProvider).show();
                    },
                  ),
                  const SizedBox(width: 8),
                  // Style Filter Dropdown
                  FilterDropdown(
                    label: 'Style',
                    selectedValues: ref.watch(filterProvider).styles.toSet(),
                    items: Categories.styles
                        .map((style) => PopupMenuItem(
                              value: style,
                              child: Text(categoryToDisplayName(style)),
                            ))
                        .toList(),
                    onSelected: (value) {
                      if (value.isEmpty) {
                        // Reset style filters
                        ref.read(filterProvider.notifier).updateFilters(
                          styles: [],
                        );
                      } else {
                        ref.read(filterProvider.notifier).toggleStyle(value);
                      }
                      ref.invalidate(hmItemProvider);
                      ref.read(discoverProvider.notifier).updateState(
                        currentIndex: 0,
                        currentImageIndex: 0,
                        previousIndices: [],
                      );
                      ref.read(overlayProvider).show();
                    },
                  ),
                  const Spacer(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: bottomPadding),
                child: Builder(
                  builder: (context) {
                    if (itemState.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${itemState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Reset error state and retry loading
                                ref.read(hmItemProvider.notifier).refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (itemState.items.isEmpty) {
                      if (itemState.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No items to discover',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Reset filters and refresh
                                ref
                                    .read(filterProvider.notifier)
                                    .resetFilters();
                                ref.read(hmItemProvider.notifier).refresh();
                              },
                              icon: const Icon(Ionicons.refresh_outline),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (discoverState.currentIndex >= itemState.items.length) {
                      if (itemState.hasMore) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No more items to discover',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Reset the state and check for new items
                                ref.read(discoverProvider.notifier).updateState(
                                  currentIndex: 0,
                                  currentImageIndex: 0,
                                  previousIndices: [],
                                );
                                ref.read(hmItemProvider.notifier).refresh();
                              },
                              icon: const Icon(Ionicons.refresh_outline),
                              label: const Text('Check for new items'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final animation = CurvedAnimation(
                      parent: slideController,
                      curve: slideOutTween == Offset.zero
                          ? Curves.easeOutBack
                          : Curves.easeOutQuart,
                    );

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background card (next card)
                            if (discoverState.currentIndex + 1 <
                                itemState.items.length)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    // Only show next card when current card is moving
                                    final showNextCard = _isDragging ||
                                        slideController.isAnimating;
                                    final scale = showNextCard
                                        ? 0.95 + (0.05 * animation.value)
                                        : 0.95;
                                    final opacity = (slideController.isAnimating
                                            ? animation.value
                                            : _isDragging
                                                ? (dragOffset.distance /
                                                    (size.width / 2))
                                                : 0.0)
                                        .clamp(0.0, 1.0);

                                    return Opacity(
                                      opacity: opacity,
                                      child: Transform(
                                        transform: Matrix4.identity()
                                          ..translate(0.0, 0.0, 0.0)
                                          ..scale(scale),
                                        alignment: Alignment.center,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: HMDiscoverCard(
                                    key: ValueKey<String>(itemState
                                        .items[discoverState.currentIndex + 1]
                                        .id),
                                    item: itemState
                                        .items[discoverState.currentIndex + 1],
                                    isCurrentCard: false,
                                  ),
                                ),
                              ),
                            // Top card (current card)
                            Positioned.fill(
                              child: GestureDetector(
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: (details) => _onPanEnd(details, size),
                                onTapUp: (details) => _handleTapUp(
                                    details, itemState.items, discoverState),
                                child: ValueListenableBuilder<double>(
                                  valueListenable: animation,
                                  builder: (context, value, child) {
                                    final offset = slideOutTween != null
                                        ? Offset.lerp(
                                            dragOffset, slideOutTween, value)!
                                        : dragOffset;
                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001) // perspective
                                        ..translate(offset.dx, offset.dy,
                                            1.0) // Ensure it's above background card
                                        ..rotateZ(offset.dx / size.width * 0.4),
                                      alignment: Alignment.center,
                                      child: Stack(
                                        children: [
                                          HMDiscoverCard(
                                            key: ValueKey<String>(itemState
                                                .items[
                                                    discoverState.currentIndex]
                                                .id),
                                            item: itemState.items[
                                                discoverState.currentIndex],
                                            currentImageIndex:
                                                discoverState.currentImageIndex,
                                            isCurrentCard: true,
                                          ),
                                          if (_isDragging)
                                            _buildOverlays(offset, size),
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
                  },
                ),
              ),
            ),
          ],
        ),
        // Action bar overlay
        if (itemState.items.isNotEmpty &&
            discoverState.currentIndex < itemState.items.length)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding - 21,
            child: ActionBar(
              isDragging: _isDragging,
              dragOffset: dragOffset,
              screenWidth: size.width,
              bigButtonHeight: 42,
              smallButtonHeight: 32,
              onDislike: () => _handleInteraction(
                HMInteractionStatus.dislike,
              ),
              onLike: () => _handleInteraction(
                HMInteractionStatus.like,
              ),
              onAddToCart: () {},
            ),
          ),
      ],
    );
  }

  void _handleTapUp(
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

    // Update the image index with a very small delay to ensure smooth transition
    // This gives time for any pending image loading to complete
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        ref.read(discoverProvider.notifier).updateImageIndex(newIndex);

        // Preload the next image in the sequence immediately
        final nextIndex = (newIndex + 1) % currentItem.images.length;
        final nextImageUrl = currentItem.images[nextIndex];
        precacheImage(
          NetworkImage(
            nextImageUrl,
            headers: const {
              'Cache-Control': 'max-age=31536000', // Cache for a year
            },
          ),
          context,
          size: const Size(1000, 1000), // Hint for higher resolution
        );
      }
    });
  }

  void _handleInteraction(
    HMInteractionStatus status,
  ) async {
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(hmItemProvider).items;

    if (items.isEmpty || discoverState.currentIndex >= items.length) {
      return;
    }

    // Use upward slide animation for superlike
    await _handleAction(
      discoverState,
      items,
      status,
      Offset(0, -MediaQuery.of(context).size.height * 1.5),
    );
  }

  Future<void> _handleAction(
    DiscoverState discoverState,
    List<HMItem> items,
    HMInteractionStatus status,
    Offset targetPosition,
  ) async {
    final currentItem = items[discoverState.currentIndex];
    final success = await ref
        .read(hmInteractionsProvider.notifier)
        .updateInteraction(currentItem.id, status);

    if (success && mounted) {
      setState(() {
        slideOutTween = targetPosition;
        slideController.forward();
      });
    }
  }

  Widget _buildOverlays(Offset offset, Size size) {
    final dx = offset.dx;
    final dy = offset.dy;
    final baseOpacity = (offset.distance / size.width).clamp(0.0, 0.5);

    // Determine overlay color based on swipe direction
    Color overlayColor;
    if (dy < -20) {
      // Upward swipe - superlike (blue)
      overlayColor = Colors.blue;
    } else {
      // Horizontal swipe - like (green) or dislike (red)
      overlayColor = dx > 0 ? Colors.green : Colors.red;
    }

    return Stack(
      children: [
        // White overlay base
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(baseOpacity * 0.5),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        // Colored overlay on top
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: overlayColor.withOpacity(baseOpacity * 0.3),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        // Like overlay
        Positioned(
          top: 40,
          left: 30,
          child: Opacity(
            opacity: dx > 0 && dy.abs() < 20
                ? (dx / (size.width / 2)).clamp(0.0, 1.0)
                : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
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
            opacity: dx < 0 && dy.abs() < 20
                ? (-dx / (size.width / 2)).clamp(0.0, 1.0)
                : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
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
        // Superlike overlay
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity:
                  dy < -20 ? (-dy / (size.height / 3)).clamp(0.0, 1.0) : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(
                    color: Colors.blue,
                    width: 4,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'SUPER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
