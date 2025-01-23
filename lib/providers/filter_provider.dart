import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:flutter/material.dart';

class FilterState {
  final Season season;
  final List<Size> sizes;
  final List<HighLevelCategory> highCategories;
  final List<SpecificCategory> specificCategories;
  final List<String> colors;
  final RangeValues priceRange;
  final List<String> styles;

  FilterState({
    this.season = Season.any,
    this.sizes = const [],
    this.highCategories = const [],
    this.specificCategories = const [],
    this.colors = const [],
    this.priceRange = const RangeValues(0, 1000),
    this.styles = const [],
  });

  FilterState copyWith({
    Season? season,
    List<Size>? sizes,
    List<HighLevelCategory>? highCategories,
    List<SpecificCategory>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    return FilterState(
      season: season ?? this.season,
      sizes: sizes ?? this.sizes,
      highCategories: highCategories ?? this.highCategories,
      specificCategories: specificCategories ?? this.specificCategories,
      colors: colors ?? this.colors,
      priceRange: priceRange ?? this.priceRange,
      styles: styles ?? this.styles,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());
  FilterState? _backupState;

  void updateFilters({
    Season? season,
    List<Size>? sizes,
    List<HighLevelCategory>? highCategories,
    List<SpecificCategory>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    state = state.copyWith(
      season: season,
      sizes: sizes,
      highCategories: highCategories,
      specificCategories: specificCategories,
      colors: colors,
      priceRange: priceRange,
      styles: styles,
    );
  }

  void backupState() {
    _backupState = FilterState(
      season: state.season,
      sizes: List<Size>.from(state.sizes),
      highCategories: List<HighLevelCategory>.from(state.highCategories),
      specificCategories: List<SpecificCategory>.from(state.specificCategories),
      colors: List<String>.from(state.colors),
      priceRange: RangeValues(state.priceRange.start, state.priceRange.end),
      styles: List<String>.from(state.styles),
    );
  }

  void restoreState() {
    if (_backupState != null) {
      state = _backupState!;
      _backupState = null;
    }
  }

  void resetFilters() {
    state = FilterState();
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
