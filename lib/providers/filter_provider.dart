import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:flutter/material.dart';

class FilterState {
  final Gender gender;
  final Season season;
  final Size? size;
  final List<HighLevelCategory> highCategories;
  final List<SpecificCategory> specificCategories;
  final List<String> colors;
  final RangeValues priceRange;
  final List<String> styles;

  FilterState({
    this.gender = Gender.unisex,
    this.season = Season.any,
    this.size,
    this.highCategories = const [],
    this.specificCategories = const [],
    this.colors = const [],
    this.priceRange = const RangeValues(0, 1000),
    this.styles = const [],
  });

  FilterState copyWith({
    Gender? gender,
    Season? season,
    Size? size,
    List<HighLevelCategory>? highCategories,
    List<SpecificCategory>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    return FilterState(
      gender: gender ?? this.gender,
      season: season ?? this.season,
      size: size ?? this.size,
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

  void updateFilters({
    Gender? gender,
    Season? season,
    Size? size,
    List<HighLevelCategory>? highCategories,
    List<SpecificCategory>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    state = state.copyWith(
      gender: gender,
      season: season,
      size: size,
      highCategories: highCategories,
      specificCategories: specificCategories,
      colors: colors,
      priceRange: priceRange,
      styles: styles,
    );
  }

  void resetFilters() {
    state = FilterState();
  }
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
