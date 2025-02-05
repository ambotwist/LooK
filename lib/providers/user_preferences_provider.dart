import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';

class UserPreferencesState {
  final Sex sex;
  final List<String> topSizes;
  final Map<String, String> bottomSizes; // Map with 'waist' and 'length' keys
  final String? shoeSize;
  final String language;
  final String? phoneNumber;

  UserPreferencesState({
    this.sex = Sex.unisex,
    this.topSizes = const [],
    this.bottomSizes = const {'waist': '', 'length': ''},
    this.shoeSize,
    this.language = 'English',
    this.phoneNumber,
  });

  UserPreferencesState copyWith({
    Sex? sex,
    List<String>? topSizes,
    Map<String, String>? bottomSizes,
    String? shoeSize,
    String? language,
    String? phoneNumber,
  }) {
    return UserPreferencesState(
      sex: sex ?? this.sex,
      topSizes: topSizes ?? this.topSizes,
      bottomSizes: bottomSizes ?? this.bottomSizes,
      shoeSize: shoeSize ?? this.shoeSize,
      language: language ?? this.language,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  UserPreferencesNotifier() : super(UserPreferencesState());

  void updateSex(Sex sex) {
    state = state.copyWith(sex: sex);
  }

  void updateTopSizes(List<String> sizes) {
    state = state.copyWith(topSizes: sizes);
  }

  void updateBottomSize(String type, String size) {
    final currentSizes = Map<String, String>.from(state.bottomSizes);
    currentSizes[type] = size;
    state = state.copyWith(bottomSizes: currentSizes);
  }

  void updateShoeSize(String size) {
    state = state.copyWith(shoeSize: size);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updatePhoneNumber(String? phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  return UserPreferencesNotifier();
});
