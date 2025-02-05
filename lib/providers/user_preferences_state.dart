class UserPreferencesState {
  final String language;
  final String? phoneNumber;

  const UserPreferencesState({
    this.language = 'English',
    this.phoneNumber,
  });

  UserPreferencesState copyWith({
    String? language,
    String? phoneNumber,
  }) {
    return UserPreferencesState(
      language: language ?? this.language,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
