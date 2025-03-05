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
import 'package:lookapp/features/discover/data/models/hm_items.dart';
import 'package:lookapp/features/discover/presentation/widgets/discover_card.dart';
import 'package:lookapp/features/discover/presentation/controllers/swipe_animation_controller.dart';
import 'package:lookapp/features/discover/presentation/widgets/swipe_overlay.dart';
import 'package:lookapp/features/discover/data/repositories/item_repository.dart';
import 'package:lookapp/features/discover/data/repositories/item_interaction_repository.dart';
import 'package:lookapp/features/discover/presentation/controllers/discover_card_preloader.dart';
import 'package:lookapp/features/discover/presentation/controllers/card_interaction_controller.dart';
import 'package:lookapp/features/discover/data/providers/hm_item_provider.dart';
import 'package:lookapp/features/discover/data/providers/hm_interactions_provider.dart';
import 'package:lookapp/widgets/layout/filter_dropdown.dart';
import 'package:lookapp/widgets/layout/no_connection_screen.dart';
import 'package:lookapp/providers/connection_provider.dart';
import 'package:lookapp/widgets/layout/search_bar.dart';

// Create repository providers
final itemRepositoryProvider = Provider((ref) => ItemRepository());
final itemInteractionRepositoryProvider =
    Provider((ref) => ItemInteractionRepository());

// Override the provider with a custom provider that we'll instantiate in the widget
final activeCardInteractionController =
    Provider<CardInteractionController?>((ref) => null);

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
  late AnimationController slideController;
  late final AnimationController _shakeController;
  late SwipeAnimationController _swipeController;
  late DiscoverCardPreloader _cardPreloader;
  late CardInteractionController _interactionController;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize our controllers
    _swipeController = SwipeAnimationController(
      animationController: slideController,
      onSwipeComplete: _handleSwipeComplete,
    );

    _cardPreloader = DiscoverCardPreloader(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize the interaction controller after ref is available
    _interactionController = CardInteractionController(
      context: context,
      ref: ref,
      shakeController: _shakeController,
      swipeController: _swipeController,
    );

    // Preload images when dependencies change (e.g., after first render)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImagesForCurrentState();
    });
  }

  void _handleSwipeComplete() {
    ref.read(discoverProvider.notifier).nextCard();

    // Preload images after moving to next card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImagesForCurrentState();
    });
  }

  void _preloadImagesForCurrentState() {
    final itemState = ref.read(hmItemProvider);
    final discoverState = ref.read(discoverProvider);

    if (itemState.items.isEmpty) return;

    final currentIndex = discoverState.currentIndex;
    final currentImageIndex = discoverState.currentImageIndex;

    // Only preload if we have a valid current item
    if (currentIndex >= itemState.items.length) return;

    final currentItem = itemState.items[currentIndex];

    // Define optional items for preloading
    HMItem? nextItem;
    HMItem? queuedItem;

    if (currentIndex + 1 < itemState.items.length) {
      nextItem = itemState.items[currentIndex + 1];
    }

    if (currentIndex + 2 < itemState.items.length) {
      queuedItem = itemState.items[currentIndex + 2];
    }

    // Preload all relevant images
    _cardPreloader.preloadAllImages(
      currentItem: currentItem,
      currentImageIndex: currentImageIndex,
      nextItem: nextItem,
      queuedItem: queuedItem,
    );
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
            onPressed: () => _interactionController.handleRewind(),
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
      debugPrint(
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
                      curve: _swipeController.slideOutTween == Offset.zero
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
                                    // Get next card opacity and scale from controller
                                    final opacity = _swipeController
                                        .calculateNextCardOpacity(
                                            slideController.isAnimating, size);
                                    final scale =
                                        _swipeController.calculateNextCardScale(
                                            slideController.isAnimating);

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
                                  child: DiscoverCard(
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
                                onPanUpdate: (details) {
                                  setState(() {
                                    _swipeController.onPanUpdate(details);
                                  });
                                },
                                onPanEnd: (details) {
                                  final direction =
                                      _swipeController.onPanEnd(details, size);

                                  if (direction != SwipeDirection.none) {
                                    // Determine the interaction status based on swipe direction
                                    HMInteractionStatus status;
                                    switch (direction) {
                                      case SwipeDirection.up:
                                        status = HMInteractionStatus.superlike;
                                        break;
                                      case SwipeDirection.right:
                                        status = HMInteractionStatus.like;
                                        break;
                                      case SwipeDirection.left:
                                        status = HMInteractionStatus.dislike;
                                        break;
                                      default:
                                        return;
                                    }

                                    // Use the interaction controller to handle the interaction
                                    _interactionController.handleInteraction(
                                      status,
                                      direction,
                                    );
                                  }

                                  // Ensure UI updates when animation state changes
                                  setState(() {});
                                },
                                onTapUp: (details) =>
                                    _interactionController.handleTapUp(details,
                                        itemState.items, discoverState),
                                child: ValueListenableBuilder<double>(
                                  valueListenable: animation,
                                  builder: (context, value, child) {
                                    // Use the controller to calculate transform
                                    final transform = _swipeController
                                        .calculateCardTransform(value, size);

                                    return Transform(
                                      transform: transform,
                                      alignment: Alignment.center,
                                      child: Stack(
                                        children: [
                                          DiscoverCard(
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
                                          if (_swipeController.isDragging)
                                            SwipeOverlay(
                                              offset:
                                                  _swipeController.dragOffset,
                                              size: size,
                                            ),
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
              isDragging: _swipeController.isDragging,
              dragOffset: _swipeController.dragOffset,
              screenWidth: size.width,
              bigButtonHeight: 42,
              smallButtonHeight: 32,
              onDislike: () => _interactionController.handleInteraction(
                HMInteractionStatus.dislike,
                SwipeDirection.left,
              ),
              onLike: () => _interactionController.handleInteraction(
                HMInteractionStatus.like,
                SwipeDirection.right,
              ),
              onAddToCart: () {},
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
