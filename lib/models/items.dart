import 'package:lookapp/enums/item_enums.dart';

class Item {
  final String id;
  final String storeName;
  final String brand;
  final String storeId;
  final Sex sex;
  final String? topSize;
  final String? shoeSize;
  final String? bottomSize;
  final String highCategory;
  final String specificCategory;
  final String color;
  final List<String> styles;
  final List<Season>? seasons;
  final List<String> materials;
  final Condition condition;
  final double price;
  final int quantity;
  final String description;
  final List<String> images;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Item({
    required this.id,
    required this.storeName,
    required this.brand,
    required this.storeId,
    this.sex = Sex.unisex,
    this.topSize,
    this.shoeSize,
    this.bottomSize,
    required this.highCategory,
    required this.specificCategory,
    this.color = 'unspecified',
    required this.styles,
    this.seasons,
    this.materials = const [],
    required this.condition,
    required this.price,
    this.quantity = 1,
    this.description = '',
    required this.images,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : assert(Categories.highLevel.contains(highCategory),
            'Invalid high category'),
        assert(Categories.specific.contains(specificCategory),
            'Invalid specific category'),
        assert(topSize == null || isValidTopSize(topSize), 'Invalid top size'),
        assert(
            shoeSize == null || isValidShoeSize(shoeSize), 'Invalid shoe size'),
        assert(bottomSize == null || isValidBottomSize(bottomSize),
            'Invalid bottom size'),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Item.fromJson(Map<String, dynamic> json) {
    // Parse seasons from the database enum array
    final List<Season>? seasons = json['seasons'] != null
        ? (json['seasons'] as List)
            .map((season) => Season.values.firstWhere(
                  (e) => e.databaseValue == season.toString().toLowerCase(),
                  orElse: () => Season.summer,
                ))
            .toList()
        : null;

    return Item(
      id: json['id'] as String,
      storeName: json['store_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      sex: Sex.values.firstWhere(
        (e) =>
            e.databaseValue ==
            (json['sex'] as String? ?? 'unisex').toLowerCase(),
        orElse: () => Sex.unisex,
      ),
      topSize: json['top_size'] as String?,
      shoeSize: json['shoe_size'] as String?,
      bottomSize: json['bottom_size'] as String?,
      highCategory: json['high_category'] as String? ?? 'tops',
      specificCategory: json['specific_category'] as String? ?? 't-shirts',
      color: json['color']?[0] as String? ?? 'unspecified',
      styles: List<String>.from(json['styles'] ?? []),
      seasons: seasons,
      materials: List<String>.from(json['materials'] ?? []),
      condition: Condition.values.firstWhere(
        (e) =>
            e.databaseValue ==
            (json['condition'] as String? ?? 'good').toLowerCase(),
        orElse: () => Condition.good,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      description: json['description'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert seasons to database format
    final List<String>? seasonNames =
        seasons?.map((s) => s.databaseValue).toList();

    // Add the appropriate size field based on category
    final Map<String, dynamic> sizeField = switch (highCategory) {
      'tops' when topSize != null => {'top_size': topSize},
      'shoes' when shoeSize != null => {'shoe_size': shoeSize},
      'bottoms' when bottomSize != null => {'bottom_size': bottomSize},
      _ => {},
    };

    return {
      'id': id,
      'store_name': storeName,
      'brand': brand,
      'store_id': storeId,
      'sex': sex.databaseValue,
      ...sizeField,
      'high_category': highCategory,
      'specific_category': specificCategory,
      'color': color,
      'styles': styles,
      'seasons': seasonNames,
      'materials': materials,
      'condition': condition.databaseValue,
      'price': price,
      'quantity': quantity,
      'description': description,
      'images': images,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
