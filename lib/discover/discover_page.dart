import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/discover/widgets/action_bar.dart';
import 'package:lookapp/discover/providers/discover_provider.dart';
import 'package:lookapp/discover/providers/interactions_provider.dart';
import 'package:lookapp/discover/providers/item_provider.dart';
import 'package:lookapp/widgets/layout/no_connection_screen.dart';
import 'package:lookapp/providers/connection_provider.dart';
import 'package:lookapp/discover/animations/slide_animation.dart';
import 'package:lookapp/discover/animations/shake_animation.dart';
import 'package:lookapp/discover/animations/overlay_animation.dart';
import 'package:lookapp/discover/animations/card_animation.dart';
import 'package:lookapp/discover/helpers/interaction_handler.dart';
import 'package:lookapp/discover/widgets/card_stack.dart';
import 'package:lookapp/discover/widgets/discover_app_bar.dart';
import 'package:lookapp/discover/widgets/filter_row.dart';

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
  late AnimationController slideController;
  late AnimationController _shakeController;

  // Animation classes
  late SlideAnimation _slideAnimation;
  late ShakeAnimation _shakeAnimation;
  late OverlayAnimation _overlayAnimation;
  late CardAnimation _cardAnimation;

  // Interaction handler
  late InteractionHandler _interactionHandler;

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

    // Initialize animation classes
    _slideAnimation = SlideAnimation(
      controller: slideController,
      setState: setState,
      onCardCompleted: () => ref.read(discoverProvider.notifier).nextCard(),
    );
    _shakeAnimation = ShakeAnimation(controller: _shakeController);
    _overlayAnimation = OverlayAnimation();
    _cardAnimation = CardAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize interaction handler after context is available
    _interactionHandler = InteractionHandler(
      ref: ref,
      slideAnimation: _slideAnimation,
      context: context,
      setState: setState,
      slideController: slideController,
    );
  }

  @override
  void dispose() {
    slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleRewind() {
    _shakeAnimation.shake();
    _interactionHandler.handleRewind();
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
            DiscoverAppBar(
              shakeAnimation: _shakeAnimation,
              onRewind: _handleRewind,
            ),
            const FilterRow(),
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
                  data: (itemsList) {
                    return CardStack(
                      items: itemsList,
                      discoverState: discoverState,
                      slideAnimation: _slideAnimation,
                      overlayAnimation: _overlayAnimation,
                      cardAnimation: _cardAnimation,
                      slideController: slideController,
                      onTapUp: (details, items, state) => _interactionHandler
                          .handleTapUp(details, items, state),
                      onPanUpdate: _interactionHandler.onPanUpdate,
                      onPanEnd: _interactionHandler.onPanEnd,
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
              isDragging: _slideAnimation.isDragging,
              dragOffset: _slideAnimation.dragOffset,
              screenWidth: size.width,
              bigButtonHeight: 42,
              smallButtonHeight: 32,
              onDislike: () => _interactionHandler.handleAction(
                discoverState,
                items.value!,
                InteractionStatus.dislike,
                Offset(-size.width * 1.5, 0),
              ),
              onLike: () => _interactionHandler.handleAction(
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
}
