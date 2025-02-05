import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/models/address.dart';

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response =
        await supabase.from('addresses').select().eq('user_id', userId);

    return (response as List)
        .map((json) => Address.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  } catch (e) {
    print('Error fetching addresses: $e');
    return [];
  }
});

class AddressNotifier extends StateNotifier<AsyncValue<List<Address>>> {
  AddressNotifier() : super(const AsyncValue.loading());

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response =
          await supabase.from('addresses').select().eq('user_id', userId);

      final addresses = (response as List)
          .map((json) => Address.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      state = AsyncValue.data(addresses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> upsertAddress(
    String type, {
    required String street,
    required String houseNumber,
    String? additionalInfo,
    required String zipCode,
    required String city,
    required String country,
    required String countryCode,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabase.from('addresses').upsert({
        'user_id': userId,
        'type': type,
        'street': street,
        'house_number': houseNumber,
        'additional_info': additionalInfo,
        'zip_code': zipCode,
        'city': city,
        'country': country,
        'country_code': countryCode,
      }).select();

      // Update state with new address
      final newAddress =
          Address.fromJson(Map<String, dynamic>.from(response[0]));
      state.whenData((addresses) {
        final index = addresses.indexWhere((a) => a.type == type);
        if (index >= 0) {
          addresses[index] = newAddress;
        } else {
          addresses.add(newAddress);
        }
        state = AsyncValue.data(addresses);
      });

      return true;
    } catch (e) {
      print('Error upserting address: $e');
      return false;
    }
  }
}

final addressNotifierProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<List<Address>>>((ref) {
  return AddressNotifier();
});
