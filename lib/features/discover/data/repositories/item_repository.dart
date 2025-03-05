import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lookapp/features/discover/data/models/hm_items.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception types for better error handling
class ItemRepositoryException implements Exception {
  final String message;
  final dynamic originalError;

  ItemRepositoryException(this.message, [this.originalError]);

  @override
  String toString() => 'ItemRepositoryException: $message';
}

class TimeoutException extends ItemRepositoryException {
  TimeoutException(String message, [dynamic originalError])
      : super(message, originalError);
}

class NetworkException extends ItemRepositoryException {
  NetworkException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// User preferences for filtering items
class UserPreferences {
  final Sex sex;

  const UserPreferences({
    this.sex = Sex.unisex,
  });
}

/// Repository for fetching and managing items
class ItemRepository {
  final SupabaseClient _supabase;
  static const int pageSize = 20;
  static const Duration timeoutDuration = Duration(seconds: 15);

  ItemRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch items with filtering and pagination
  Future<List<HMItem>> getItems({
    required FilterState filters,
    required UserPreferences userPrefs,
    required List<String> excludeItemIds,
    required int offset,
    int limit = pageSize,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ItemRepositoryException('Not authenticated');
      }

      var query = _supabase.from('hm_items').select();

      // Apply filters using Supabase query builder
      if (excludeItemIds.isNotEmpty) {
        query = query.not('id', 'in', excludeItemIds);
      }

      if (userPrefs.sex != Sex.unisex) {
        query = query.inFilter(
            'sex', [userPrefs.sex.databaseValue, Sex.unisex.databaseValue]);
      }

      if (filters.seasons.isNotEmpty) {
        query = query.overlaps(
            'seasons', filters.seasons.map((s) => s.databaseValue).toList());
      }

      if (filters.highCategories.isNotEmpty) {
        query = query.inFilter('high_category', filters.highCategories);
      }

      if (filters.specificCategories.isNotEmpty) {
        query = query.inFilter('specific_category', filters.specificCategories);
      }

      if (filters.colors.isNotEmpty) {
        query = query.overlaps('colors', filters.colors);
      }

      if (filters.styles.isNotEmpty) {
        query = query.overlaps('styles', filters.styles);
      }

      // Apply price range filter
      query = query
          .gte('price', filters.priceRange.start)
          .lte('price', filters.priceRange.end);

      // Apply size filters if needed
      if (filters.topSizes.isNotEmpty) {
        query = query.or(
            'top_size.in.(${filters.topSizes.map((s) => "'$s'").join(',')})');
      }
      if (filters.bottomSizes.isNotEmpty) {
        query = query.or(
            'bottom_size.in.(${filters.bottomSizes.map((s) => "'$s'").join(',')})');
      }
      if (filters.shoeSizes.isNotEmpty) {
        query = query.or(
            'shoe_size.in.(${filters.shoeSizes.map((s) => "'$s'").join(',')})');
      }

      // Count query with timeout
      final totalItemCount = await _executeWithTimeout<int>(
        () async {
          final countResponse = await query.count();
          return countResponse.count;
        },
        'Count query timed out',
      );

      if (totalItemCount == 0) {
        return [];
      }

      // Fetch items with pagination
      final items = await _executeWithTimeout<List<HMItem>>(
        () async {
          final response = await query
              .order('updated_at', ascending: false)
              .range(offset, offset + limit - 1);

          return (response as List)
              .map((item) => HMItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        },
        'Items query timed out',
      );

      return items;
    } catch (e, stackTrace) {
      debugPrint('Error fetching items: $e');
      debugPrint('Stack trace: $stackTrace');

      if (e is TimeoutException) {
        rethrow;
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        throw NetworkException('Network error while fetching items', e);
      } else if (e is ItemRepositoryException) {
        rethrow;
      } else {
        throw ItemRepositoryException('Error fetching items', e);
      }
    }
  }

  /// Get total count of items matching filters
  Future<int> getItemCount({
    required FilterState filters,
    required UserPreferences userPrefs,
    required List<String> excludeItemIds,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ItemRepositoryException('Not authenticated');
      }

      var query = _supabase.from('hm_items').select();

      // Apply the same filters as getItems
      if (excludeItemIds.isNotEmpty) {
        query = query.not('id', 'in', excludeItemIds);
      }

      if (userPrefs.sex != Sex.unisex) {
        query = query.inFilter(
            'sex', [userPrefs.sex.databaseValue, Sex.unisex.databaseValue]);
      }

      // Apply all the other filters...
      // [Note: This should include the same filtering logic as getItems]

      // Just get count
      final countResponse = await query.count();
      return countResponse.count;
    } catch (e) {
      debugPrint('Error counting items: $e');
      throw ItemRepositoryException('Error counting items', e);
    }
  }

  /// Get an item by ID
  Future<HMItem?> getItemById(String itemId) async {
    try {
      final response =
          await _supabase.from('hm_items').select().eq('id', itemId).single();

      return HMItem.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching item $itemId: $e');
      return null;
    }
  }

  /// Helper method to execute queries with timeout
  Future<T> _executeWithTimeout<T>(
    Future<T> Function() query,
    String timeoutMessage,
  ) async {
    final completer = Completer<T>();

    // Set timeout
    final timer = Timer(timeoutDuration, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(timeoutMessage,
              'Request timed out after ${timeoutDuration.inSeconds}s'),
        );
      }
    });

    try {
      // Execute the query
      final result = await query();

      // Complete with result if not already completed due to timeout
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e) {
      // Complete with error if not already completed due to timeout
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    } finally {
      // Cancel the timer
      timer.cancel();
    }

    return completer.future;
  }
}
