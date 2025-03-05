import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/provider_refresh.dart';
import 'dart:async';

import 'package:lookapp/features/discover/data/models/hm_items.dart';

// State class to hold both items and loading state
class HMItemsState {
  final List<HMItem> items;
  final bool isLoading;
  final bool hasMore;
  final int currentOffset;
  final String? error;

  HMItemsState({
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.currentOffset = 0,
    this.error,
  });

  HMItemsState copyWith({
    List<HMItem>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentOffset,
    String? error,
  }) {
    return HMItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      error: error,
    );
  }
}

class HMItemNotifier extends StateNotifier<HMItemsState> {
  HMItemNotifier(this.ref) : super(HMItemsState(items: []));

  final Ref ref;
  static const int pageSize = 20;
  bool _isLoadingMore = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 15);

  Future<void> loadMore({bool refresh = false}) async {
    // If already loading or no more items and not refreshing, return early
    if (_isLoadingMore || (!state.hasMore && !refresh)) {
      print(
          'Skipping loadMore: _isLoadingMore=$_isLoadingMore, state.hasMore=${state.hasMore}, refresh=$refresh');
      return;
    }

    // Set loading flag
    _isLoadingMore = true;
    print(
        'Starting loadMore: refresh=$refresh, currentOffset=${state.currentOffset}, currentItems=${state.items.length}');

    try {
      final filterState = ref.read(filterProvider);
      final userPrefs = ref.read(userPreferencesProvider);

      // Reset offset if refreshing, otherwise use current offset
      final offset = refresh ? 0 : state.currentOffset;

      // Only update loading state if this is a refresh
      if (refresh) {
        state = state.copyWith(isLoading: true);
      }

      // Get user ID with better error handling
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      // Create a timeout for the request
      final interactionsCompleter = Completer<List<dynamic>>();

      // Start the timeout timer
      Timer? timeoutTimer = Timer(timeoutDuration, () {
        if (!interactionsCompleter.isCompleted) {
          interactionsCompleter.completeError(
              TimeoutException('Request timed out', timeoutDuration));
        }
      });

      // Make the actual request
      supabase
          .from('hm_interactions')
          .select('item_id')
          .eq('user_id', userId)
          .not('interaction_type', 'is', null)
          .then((value) {
        if (!interactionsCompleter.isCompleted) {
          interactionsCompleter.complete(value);
        }
      }).catchError((error) {
        if (!interactionsCompleter.isCompleted) {
          interactionsCompleter.completeError(error);
        }
      });

      // Wait for either the result or timeout
      final interactions = await interactionsCompleter.future;

      // Cancel the timeout timer if it's still active
      timeoutTimer.cancel();
      timeoutTimer = null;

      print('Fetching interactions for user $userId');
      final interactedItemIds = (interactions)
          .map((interaction) => interaction['item_id'] as String)
          .toList();
      print('Found ${interactedItemIds.length} interactions');

      print('Fetching HM items from offset $offset...');
      var query = supabase.from('hm_items').select();

      // Apply filters using Supabase query builder
      if (interactedItemIds.isNotEmpty) {
        query = query.not('id', 'in', interactedItemIds);
      }

      if (userPrefs.sex != Sex.unisex) {
        query = query.inFilter(
            'sex', [userPrefs.sex.databaseValue, Sex.unisex.databaseValue]);
      }

      if (filterState.seasons.isNotEmpty) {
        query = query.overlaps('seasons',
            filterState.seasons.map((s) => s.databaseValue).toList());
      }

      if (filterState.highCategories.isNotEmpty) {
        query = query.inFilter('high_category', filterState.highCategories);
      }

      if (filterState.specificCategories.isNotEmpty) {
        query =
            query.inFilter('specific_category', filterState.specificCategories);
      }

      if (filterState.colors.isNotEmpty) {
        query = query.overlaps('colors', filterState.colors);
      }

      if (filterState.styles.isNotEmpty) {
        query = query.overlaps('styles', filterState.styles);
      }

      // Apply price range filter
      query = query
          .gte('price', filterState.priceRange.start)
          .lte('price', filterState.priceRange.end);

      // Apply size filters if needed
      if (filterState.topSizes.isNotEmpty) {
        query = query.or(
            'top_size.in.(${filterState.topSizes.map((s) => "'$s'").join(',')})');
      }
      if (filterState.bottomSizes.isNotEmpty) {
        query = query.or(
            'bottom_size.in.(${filterState.bottomSizes.map((s) => "'$s'").join(',')})');
      }
      if (filterState.shoeSizes.isNotEmpty) {
        query = query.or(
            'shoe_size.in.(${filterState.shoeSizes.map((s) => "'$s'").join(',')})');
      }

      // Create a timeout for the count query
      final countCompleter = Completer<int>();

      // Start the timeout timer
      timeoutTimer = Timer(timeoutDuration, () {
        if (!countCompleter.isCompleted) {
          countCompleter.completeError(
              TimeoutException('Count query timed out', timeoutDuration));
        }
      });

      // Make the actual count request - use count() instead of fetching all items
      final countQuery = query.count();
      countQuery.then((value) {
        if (!countCompleter.isCompleted) {
          // Extract the count from the response
          final count = value.count;
          countCompleter.complete(count);
        }
      }).catchError((error) {
        if (!countCompleter.isCompleted) {
          countCompleter.completeError(error);
        }
      });

      // Wait for either the result or timeout
      final totalCount = await countCompleter.future;

      // Cancel the timeout timer if it's still active
      timeoutTimer.cancel();
      timeoutTimer = null;

      print('Total available items: $totalCount');

      if (totalCount == 0) {
        state = state.copyWith(
          items: [],
          isLoading: false,
          hasMore: false,
          currentOffset: 0,
          error: null,
        );
        // Reset retry count on success
        _retryCount = 0;
        print(
            'loadMore completed: items=${state.items.length}, hasMore=${state.hasMore}, nextOffset=${state.currentOffset}');
        return;
      }

      // Create a timeout for the items query
      final itemsCompleter = Completer<List<dynamic>>();

      // Start the timeout timer
      timeoutTimer = Timer(timeoutDuration, () {
        if (!itemsCompleter.isCompleted) {
          itemsCompleter.completeError(
              TimeoutException('Items query timed out', timeoutDuration));
        }
      });

      // Make the actual items request
      query
          .order('updated_at', ascending: false)
          .range(offset, offset + pageSize - 1)
          .then((value) {
        if (!itemsCompleter.isCompleted) {
          itemsCompleter.complete(value);
        }
      }).catchError((error) {
        if (!itemsCompleter.isCompleted) {
          itemsCompleter.completeError(error);
        }
      });

      // Wait for either the result or timeout
      final response = await itemsCompleter.future;

      // Cancel the timeout timer if it's still active
      timeoutTimer.cancel();
      timeoutTimer = null;

      print('Response received. Number of items: ${response.length}');

      final newItems = (response)
          .map((item) => HMItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      // Calculate if there are more items
      final hasMore = offset + newItems.length < totalCount;

      // Update items list based on refresh or append
      final updatedItems = refresh ? newItems : [...state.items, ...newItems];

      // Update state with new items and reset error
      state = state.copyWith(
        items: updatedItems,
        isLoading: false,
        hasMore: hasMore,
        currentOffset:
            refresh ? newItems.length : state.currentOffset + newItems.length,
        error: null,
      );

      // Reset retry count on success
      _retryCount = 0;

      print(
          'Updated state - Total items: ${updatedItems.length}, Has more: $hasMore, Next offset: ${state.currentOffset}');
      print(
          'loadMore completed: items=${state.items.length}, hasMore=${state.hasMore}, nextOffset=${state.currentOffset}');
    } catch (e, stackTrace) {
      print('Error in hmItemProvider: $e');
      print('Stack trace: $stackTrace');

      // Implement retry logic for certain errors
      if (e is TimeoutException ||
          e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        if (_retryCount < maxRetries) {
          _retryCount++;
          print('Retrying loadMore (attempt $_retryCount of $maxRetries)...');
          _isLoadingMore = false;

          // Add a small delay before retrying
          await Future.delayed(const Duration(seconds: 1));
          return loadMore(refresh: refresh);
        }
      }

      // Keep existing items on error, just update error state
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load items. Please try again.',
        hasMore: state.hasMore, // Maintain current hasMore state
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  void refresh() {
    // Reset retry count on manual refresh
    _retryCount = 0;
    loadMore(refresh: true);
  }
}

final hmItemProvider =
    StateNotifierProvider<HMItemNotifier, HMItemsState>((ref) {
  final notifier = HMItemNotifier(ref);

  // Watch the refresh provider to trigger updates
  ref.watch(refreshProvider);

  // Initial load
  notifier.loadMore(refresh: true);

  return notifier;
});
