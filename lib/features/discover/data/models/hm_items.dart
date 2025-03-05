import 'package:lookapp/enums/item_enums.dart';

class HMItem {
  final String id;
  final String? name;
  final String? storeName;
  final String? brand;
  final String? storeId;
  final Sex sex;
  final String? topSize;
  final String? shoeSize;
  final String? bottomSize;
  final String highCategory;
  final String specificCategory;
  final List<String> colors;
  final List<String> styles;
  final List<Season>? seasons;
  final List<String> materials;
  final Condition condition;
  final double price;
  final String? description;
  final List<String> images;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final String? externalId;
  final String? fit;
  final List<String>? measurements;
  final String? garmentLength;
  final String? waistRise;
  final String? currency;
  final String? rgbColor;
  final String? baseProductCode;
  final String? assortmentType;
  final List<String>? supercategories;

  HMItem({
    required this.id,
    this.name,
    this.storeName,
    this.brand,
    this.storeId,
    required this.sex,
    this.topSize,
    this.shoeSize,
    this.bottomSize,
    required this.highCategory,
    required this.specificCategory,
    this.colors = const [],
    this.styles = const [],
    this.seasons,
    this.materials = const [],
    required this.condition,
    required this.price,
    this.description,
    required this.images,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.externalId,
    this.fit,
    this.measurements,
    this.garmentLength,
    this.waistRise,
    this.currency,
    this.rgbColor,
    this.baseProductCode,
    this.assortmentType,
    this.supercategories,
  });

  factory HMItem.fromJson(Map<String, dynamic> json) {
    try {
      // Parse seasons from the database enum array
      List<Season>? seasons;
      try {
        seasons = json['season'] != null
            ? (json['season'] as List)
                .map((season) => Season.values.firstWhere(
                      (e) => e.databaseValue == season.toString().toLowerCase(),
                      orElse: () => Season.summer,
                    ))
                .toList()
            : null;
      } catch (e) {
        print('Error parsing seasons: $e');
        seasons = null;
      }

      // Ensure id is a string
      final String id = json['id']?.toString() ?? '';
      if (id.isEmpty) {
        throw const FormatException('Item ID is empty or null');
      }

      // Handle potentially null numeric values
      double price;
      try {
        price = (json['price'] as num?)?.toDouble() ?? 0.0;
      } catch (e) {
        print('Error parsing price: $e');
        price = 0.0;
      }

      // Handle potentially null array values with detailed error logging
      List<String> parseStringList(String key) {
        try {
          if (json[key] == null) return const [];
          if (json[key] is! List) {
            print('Warning: $key is not a List: ${json[key]}');
            return const [];
          }
          return (json[key] as List)
              .where((item) => item != null)
              .map((item) => item.toString())
              .toList();
        } catch (e) {
          print('Error parsing $key: $e');
          return const [];
        }
      }

      // Handle measurements separately as it might contain complex strings
      List<String>? measurements;
      try {
        if (json['measurements'] != null) {
          if (json['measurements'] is List) {
            measurements = (json['measurements'] as List)
                .where((item) => item != null)
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty)
                .toList();
          } else {
            print(
                'Warning: measurements is not a List: ${json['measurements']}');
            measurements = null;
          }
        }
      } catch (e) {
        print('Error parsing measurements: $e');
        measurements = null;
      }

      // Handle potentially null string values with defaults
      String? safeString(String key) {
        try {
          final value = json[key];
          if (value == null) return null;
          return value.toString();
        } catch (e) {
          print('Error parsing $key: $e');
          return null;
        }
      }

      final String highCategory = safeString('high_category') ?? 'tops';
      final String specificCategory =
          safeString('specific_category') ?? 't-shirts';

      // Parse all list fields with safety checks
      final images = parseStringList('images');
      // Ensure we have at least one image
      if (images.isEmpty) {
        images.add('https://via.placeholder.com/400x600?text=No+Image');
      }

      final colors = parseStringList('colors');
      final styles = parseStringList('styles');
      final materials = parseStringList('materials');
      final tags = parseStringList('tags');
      final supercategories = json['supercategories'] != null
          ? parseStringList('supercategories')
          : null;

      // Safely parse dates
      DateTime? parseDate(String key) {
        try {
          final value = json[key];
          if (value == null) return null;
          if (value is String) {
            return DateTime.parse(value);
          }
          return null;
        } catch (e) {
          print('Error parsing date $key: $e');
          return null;
        }
      }

      final createdAt = parseDate('created_at');
      final updatedAt = parseDate('updated_at');

      // Safely parse boolean
      bool? parseBool(String key) {
        try {
          final value = json[key];
          if (value == null) return null;
          if (value is bool) return value;
          if (value is String) {
            return value.toLowerCase() == 'true';
          }
          if (value is num) {
            return value != 0;
          }
          return null;
        } catch (e) {
          print('Error parsing boolean $key: $e');
          return null;
        }
      }

      final isActive = parseBool('is_active') ?? true;

      return HMItem(
        id: id,
        name: safeString('name'),
        storeName: safeString('store_name'),
        brand: safeString('brand'),
        storeId: safeString('store_id'),
        sex: Sex.values.firstWhere(
          (e) =>
              e.databaseValue == (safeString('sex') ?? 'unisex').toLowerCase(),
          orElse: () => Sex.unisex,
        ),
        topSize: safeString('top_size'),
        shoeSize: safeString('shoe_size'),
        bottomSize: safeString('bottom_size'),
        highCategory: highCategory,
        specificCategory: specificCategory,
        colors: colors,
        styles: styles,
        seasons: seasons,
        materials: materials,
        condition: Condition.values.firstWhere(
          (e) =>
              e.databaseValue ==
              (safeString('condition') ?? 'good').toLowerCase(),
          orElse: () => Condition.good,
        ),
        price: price,
        description: safeString('description'),
        images: images,
        tags: tags,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: isActive,
        externalId: safeString('external_id'),
        fit: safeString('fit'),
        measurements: measurements,
        garmentLength: safeString('garment_length'),
        waistRise: safeString('waist_rise'),
        currency: safeString('currency'),
        rgbColor: safeString('rgb_color'),
        baseProductCode: safeString('base_product_code'),
        assortmentType: safeString('assortment_type'),
        supercategories: supercategories,
      );
    } catch (e, stackTrace) {
      print('Error in HMItem.fromJson: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');

      // Instead of rethrowing, try to create a minimal valid item
      try {
        final String id = json['id']?.toString() ??
            'error_${DateTime.now().millisecondsSinceEpoch}';
        return HMItem(
          id: id,
          name: 'Error loading item',
          brand: 'Unknown',
          highCategory: 'tops',
          specificCategory: 't-shirts',
          colors: const [],
          styles: const [],
          materials: const [],
          condition: Condition.good,
          price: 0.0,
          sex: Sex.unisex,
          images: [
            'https://via.placeholder.com/400x600?text=Error+Loading+Item'
          ],
        );
      } catch (fallbackError) {
        print('Even fallback creation failed: $fallbackError');
        rethrow; // Only rethrow if we can't even create a fallback item
      }
    }
  }
}
