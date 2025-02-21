import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/main/pages/discover/action_bar.dart';
import 'package:lookapp/main/pages/fliter/filter_page.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/interactions_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/widgets/layout/filter_dropdown.dart';
import 'package:lookapp/widgets/layout/no_connection_screen.dart';
import 'package:lookapp/providers/connection_provider.dart';

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
  }

  @override
  void dispose() {
    slideController.dispose();
    _shakeController.dispose();
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
    const positionThreshold = 0.4;
    const velocityThreshold = 1000.0; // pixels per second

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
          const velocityMultiplier =
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

  void _handleRewind() async {
    final discoverNotifier = ref.read(discoverProvider.notifier);
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(itemsProvider).asData?.value;

    if (discoverState.previousIndices.isEmpty || items == null) {
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
          await ref.read(interactionsProvider.notifier).updateInteraction(
                previousItem.id,
                null, // Pass null to delete the interaction
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

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(connectionProvider);
    final items = ref.watch(itemsProvider);
    final discoverState = ref.watch(discoverProvider);
    final size = MediaQuery.of(context).size;
    const bottomPadding = 36.0;

    // If there's no internet connection, show the no connection screen
    if (!isConnected) {
      return const NoConnectionScreen();
    }

    return Stack(
      children: [
        Column(
          children: [
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
                              ref.invalidate(itemsProvider);
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
                      ref.invalidate(itemsProvider);
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
                      ref.invalidate(itemsProvider);
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
                      ref.invalidate(itemsProvider);
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
                child: items.when(
                  error: (error, stackTrace) => Center(
                    child: Text('Error: $error'),
                  ),
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

                    final animation = CurvedAnimation(
                      parent: slideController,
                      curve: slideOutTween == Offset.zero
                          ? Curves.easeOutBack
                          : Curves.easeOutQuart,
                    );

                    return Stack(
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
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        // Action bar overlay - positioned relative to the entire screen
        if (items.hasValue &&
            items.value!.isNotEmpty &&
            discoverState.currentIndex < items.value!.length)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding - 21, // Half of bigButtonHeight
            child: ActionBar(
              isDragging: _isDragging,
              dragOffset: dragOffset,
              screenWidth: size.width,
              bigButtonHeight: 42,
              smallButtonHeight: 32,
              onDislike: () => _handleAction(
                discoverState,
                items.value!,
                InteractionStatus.dislike,
                Offset(-size.width * 1.5, 0),
              ),
              onLike: () => _handleAction(
                discoverState,
                items.value!,
                InteractionStatus.like,
                Offset(size.width * 1.5, 0),
              ),
            ),
          ),
      ],
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
    final dx = offset.dx;
    final dy = offset.dy;
    final baseOpacity = (offset.distance / size.width).clamp(0.0, 0.5);

    // Determine overlay color based on drag direction
    Color overlayColor = Colors.white;
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        overlayColor = Colors.green;
      } else {
        overlayColor = Colors.red;
      }
    } else {
      if (dy > 0) {
        overlayColor = Colors.purple;
      } else {
        overlayColor = const Color.fromARGB(255, 225, 73, 17);
      }
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
            opacity: (dx > 0 && dx.abs() > dy.abs())
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
            opacity: (dx < 0 && dx.abs() > dy.abs())
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
        // Too Expensive overlay (bottom)
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: (dy < 0 && dy.abs() > dx.abs())
                  ? (-dy / (size.height / 4)).clamp(0.0, 1.0)
                  : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 225, 73, 17),
                    width: 4,
                  ),
                ),
                child: const Text(
                  'TOO EXPENSIVE',
                  style: TextStyle(
                    color: Color.fromARGB(255, 225, 73, 17),
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
              opacity: (dy > 0 && dy.abs() > dx.abs())
                  ? (dy / (size.height / 4)).clamp(0.0, 1.0)
                  : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
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
    );
  }
}
