import 'package:lookapp/enums/item_enums.dart';

class Item {
  final String id;
  final String name;
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
    required this.name,
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
      name: json['name'] as String,
      brand: json['brand'] as String,
      storeId: json['store_id'] as String,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'] as String,
      ),
      size: Size.values.firstWhere(
        (e) => e.name == json['size'] as String,
      ),
      highCategory: HighLevelCategory.values.firstWhere(
        (e) => e.name == json['high_category'] as String,
      ),
      specificCategory: SpecificCategory.values.firstWhere(
        (e) => e.name == json['specific_category'] as String,
      ),
      color: json['color'] as String,
      styles: List<String>.from(json['styles'] as List),
      season: Season.values.firstWhere(
        (e) => e.name == json['season'] as String,
      ),
      materials: List<String>.from(json['materials'] as List),
      condition: Condition.values.firstWhere(
        (e) => e.name == json['condition'] as String,
      ),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      description: json['description'] as String,
      images: List<String>.from(json['images'] as List),
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
