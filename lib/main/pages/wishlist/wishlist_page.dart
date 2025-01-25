import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/providers/wishlist_provider.dart';
import 'package:lookapp/main/pages/discover/dicover_card.dart';
import 'package:lookapp/enums/item_enums.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule the refresh after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refreshWishlistItems(ref);
      }
    });
  }

  void _showItemDetails(BuildContext context, Item item) {
    int currentImageIndex = 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.of(context).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: StatefulBuilder(
            builder: (context, setState) => GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {}, // Prevent dialog from closing when tapping the card
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: GestureDetector(
                      onTapUp: (details) {
                        final width = MediaQuery.of(context).size.width;
                        final tapPosition = details.globalPosition.dx;
                        final tapThreshold = width / 2;

                        setState(() {
                          if (tapPosition < tapThreshold) {
                            // Left tap
                            if (currentImageIndex > 0) {
                              currentImageIndex--;
                            }
                          } else {
                            // Right tap
                            if (currentImageIndex < item.images.length - 1) {
                              currentImageIndex++;
                            }
                          }
                        });
                      },
                      child: DiscoverCard(
                        item: item,
                        isCurrentCard: true,
                        currentImageIndex: currentImageIndex,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            // TODO: Implement add to cart functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final wishlistItemsState = ref.watch(wishlistItemsProvider);

    return wishlistItemsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No items in wishlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return WishlistItemCard(
              item: item,
              onTap: () => _showItemDetails(context, item),
            );
          },
        );
      },
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage(item.images.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.brand} ${item.specificCategory.displayName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toInt()}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
