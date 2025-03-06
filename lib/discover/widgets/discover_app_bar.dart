import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/widgets/layout/search_bar.dart';
import 'package:lookapp/discover/animations/shake_animation.dart';

class DiscoverAppBar extends ConsumerWidget {
  final ShakeAnimation shakeAnimation;
  final VoidCallback onRewind;

  const DiscoverAppBar({
    Key? key,
    required this.shakeAnimation,
    required this.onRewind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      toolbarHeight: 42,
      actions: [
        shakeAnimation.buildShakeAnimatedWidget(
          child: IconButton(
            icon: const Icon(Ionicons.arrow_undo, size: 28),
            onPressed: onRewind,
          ),
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const CustomSearchBar(
              hintText: 'What are you looking for?',
            ),
          ),
        ),
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
}
