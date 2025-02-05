import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';

class UserPreferencesState {
  final Sex sex;
  final List<String> topSizes;
  final Map<String, String> bottomSizes; // Map with 'waist' and 'length' keys
  final String? shoeSize;
  final String language;
  final String? phoneNumber;
  final String? dialCode;
  final String? isoCode;
  final Map<String, String> billingAddress;
  final Map<String, String> deliveryAddress;

  const UserPreferencesState({
    this.sex = Sex.unisex,
    this.topSizes = const [],
    this.bottomSizes = const {'waist': '', 'length': ''},
    this.shoeSize,
    this.language = 'English',
    this.phoneNumber,
    this.dialCode,
    this.isoCode,
    this.billingAddress = const {
      'street': '',
      'number': '',
      'additionalInfo': '',
      'zipCode': '',
      'city': '',
      'country': '',
      'countryCode': 'US',
    },
    this.deliveryAddress = const {
      'street': '',
      'number': '',
      'additionalInfo': '',
      'zipCode': '',
      'city': '',
      'country': '',
      'countryCode': 'US',
    },
  });

  UserPreferencesState copyWith({
    Sex? sex,
    List<String>? topSizes,
    Map<String, String>? bottomSizes,
    String? shoeSize,
    String? language,
    String? phoneNumber,
    String? dialCode,
    String? isoCode,
    Map<String, String>? billingAddress,
    Map<String, String>? deliveryAddress,
  }) {
    return UserPreferencesState(
      sex: sex ?? this.sex,
      topSizes: topSizes ?? this.topSizes,
      bottomSizes: bottomSizes ?? this.bottomSizes,
      shoeSize: shoeSize ?? this.shoeSize,
      language: language ?? this.language,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dialCode: dialCode ?? this.dialCode,
      isoCode: isoCode ?? this.isoCode,
      billingAddress: billingAddress ?? this.billingAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
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

  void updateDialCode(String dialCode) {
    state = state.copyWith(dialCode: dialCode);
  }

  void updateIsoCode(String isoCode) {
    state = state.copyWith(isoCode: isoCode);
  }

  void updateBillingAddress(Map<String, String> address) {
    state = state.copyWith(billingAddress: address);
  }

  void updateDeliveryAddress(Map<String, String> address) {
    state = state.copyWith(deliveryAddress: address);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  return UserPreferencesNotifier();
});
