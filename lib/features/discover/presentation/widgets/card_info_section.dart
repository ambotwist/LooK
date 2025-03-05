import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/features/discover/presentation/widgets/card_icon_text_row.dart';
import 'package:lookapp/providers/wishlist_provider.dart';
import 'package:lookapp/test/models/hm_items.dart';

/// Section displaying product information at the bottom of the card
class CardInfoSection extends ConsumerWidget {
  final HMItem item;
  final int infoColumnIndex;
  final double height;

  const CardInfoSection({
    super.key,
    required this.item,
    this.infoColumnIndex = 0,
    this.height = 160.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.1, 0.15, 0.5, 0.7, 1.0],
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(1.0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 8.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          children: [
            _buildHeaderSection(context),
            _buildInfoColumn(ref),
          ],
        ),
      ),
    );
  }

  /// Builds the product name, brand and price section
  Widget _buildHeaderSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: height / 2.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AutoSizeText(
                    item.name ?? 'Unnamed Item',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    maxLines: 2,
                    minFontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  item.brand ?? 'Unknown Brand',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.price % 1 == 0 ? item.price.round() : item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the info column with product details and favorite button
  Widget _buildInfoColumn(WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);
    final isInWishlist = wishlistState.value?.contains(item.id) ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailsColumn(),
        // Favorite button
        SizedBox(
          height: 52,
          width: 52,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 42,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isInWishlist ? Ionicons.bookmark : Ionicons.bookmark_outline,
                key: ValueKey<bool>(isInWishlist),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            onPressed: () async {
              final success = await ref
                  .read(wishlistProvider.notifier)
                  .toggleWishlist(item.id);

              if (!success) {
                ScaffoldMessenger.of(ref.context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update wishlist'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  /// Builds the column with product details based on the info column index
  Widget _buildDetailsColumn() {
    switch (infoColumnIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.fit != null)
              CardIconTextRow(icon: Ionicons.resize, text: item.fit!),
            if (item.materials.isNotEmpty)
              CardIconTextRow(
                icon: Ionicons.pricetag,
                text: item.materials.join(', '),
              ),
            if (item.colors.isNotEmpty)
              CardIconTextRow(
                icon: Ionicons.color_palette,
                text: item.colors.join(', '),
              ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.styles.isNotEmpty)
              CardIconTextRow(
                icon: Ionicons.shirt,
                text: item.styles.join(', '),
              ),
            if (item.measurements != null)
              CardIconTextRow(
                icon: Ionicons.resize,
                text: item.measurements!.join(', '),
              ),
          ],
        );
    }
  }
}
