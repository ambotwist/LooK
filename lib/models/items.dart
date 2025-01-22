import 'package:lookapp/enums/item_enums.dart';

class Item {
  final String id;
  final String storeName;
  final String brand;
  final String storeId;
  final Gender gender;
  final Size size;
  final HighLevelCategory highCategory;
  final SpecificCategory specificCategory;
  final String color;
  final List<String> styles;
  final Season season;
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
    this.gender = Gender.unisex,
    required this.size,
    required this.highCategory,
    required this.specificCategory,
    this.color = 'unspecified',
    required this.styles,
    this.season = Season.any,
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
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      storeName: json['store_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      gender: Gender.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['gender'] as String? ?? 'unisex').toLowerCase(),
        orElse: () => Gender.unisex,
      ),
      size: Size.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['size'] as String? ?? 'm').toLowerCase(),
        orElse: () => Size.m,
      ),
      highCategory: HighLevelCategory.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['high_level_category'] as String? ?? 'tops').toLowerCase(),
        orElse: () => HighLevelCategory.tops,
      ),
      specificCategory: SpecificCategory.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['specific_category'] as String? ?? 'tShirts').toLowerCase(),
        orElse: () => SpecificCategory.tShirts,
      ),
      color: json['color']?[0] as String? ?? 'unspecified',
      styles: List<String>.from(json['styles'] ?? []),
      season: Season.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['season'] as String? ?? 'any').toLowerCase(),
        orElse: () => Season.any,
      ),
      materials: List<String>.from(json['materials'] ?? []),
      condition: Condition.values.firstWhere(
        (e) {
          final dbValue =
              (json['condition'] as String? ?? 'good').toLowerCase();
          return e == Condition.asNew
              ? dbValue == 'new'
              : e.name.toLowerCase() == dbValue;
        },
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
    return {
      'id': id,
      'store_name': storeName,
      'brand': brand,
      'store_id': storeId,
      'gender': gender,
      'size': size,
      'high_category': highCategory.name,
      'specific_category': specificCategory.name,
      'color': color,
      'styles': styles,
      'season': season,
      'materials': materials,
      'condition': condition,
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
