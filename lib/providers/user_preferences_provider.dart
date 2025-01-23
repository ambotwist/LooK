import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';

class UserPreferencesState {
  final Gender gender;

  UserPreferencesState({
    this.gender = Gender.unisex,
  });

  UserPreferencesState copyWith({
    Gender? gender,
  }) {
    return UserPreferencesState(
      gender: gender ?? this.gender,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  UserPreferencesNotifier() : super(UserPreferencesState());

  void updateGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  return UserPreferencesNotifier();
});
