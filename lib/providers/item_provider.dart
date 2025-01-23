import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/main.dart';

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  try {
    final response = await supabase.from('items').select();
    if (response.isEmpty) return [];
    final items = (response as List).map((item) {
      return Item.fromJson(Map<String, dynamic>.from(item));
    }).toList();
    return items;
  } catch (e) {
    throw 'Failed to fetch items: $e';
  }
});
