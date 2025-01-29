enum Sex {
  male,
  female,
  unisex,
}

enum Season {
  spring,
  summer,
  fall,
  winter,
}

enum Condition {
  fair,
  good,
  excellent,
  as_new,
}

// These are not enums in the database but we'll keep them as constants for type safety
class Categories {
  static const List<String> highLevel = [
    'tops',
    'bottoms',
    'shoes',
    'outerwear',
    'sportswear',
    'bags',
    'accessories',
    'formal_wear'
  ];

  static const List<String> specific = [
    't-shirts',
    'shirts',
    'tank_tops',
    'sweaters',
    'hoodies',
    'blouses',
    'polo_shirts',
    'pants',
    'jeans',
    'shorts',
    'skirts',
    'leggings',
    'sneakers',
    'boots',
    'sandals',
    'flats',
    'heels',
    'loafers',
    'jackets',
    'coats',
    'blazers',
    'vests',
    'scarves',
    'belts',
    'gloves',
    'sunglasses',
    'watches',
    'jewelry',
    'gym_tops',
    'gym_bottoms',
    'athletic_shoes',
    'bikinis',
    'one-piece_swimsuits',
    'suits',
    'dresses',
    'tuxedos'
  ];

  static const List<String> colors = [
    'black',
    'white',
    'red',
    'blue',
    'green',
    'yellow',
    'purple',
    'pink',
    'orange',
    'brown',
    'grey',
    'multi'
  ];

  static const List<String> styles = [
    'casual',
    'formal',
    'sporty',
    'vintage',
    'streetwear',
    'bohemian',
    'minimalist',
    'preppy',
    'punk',
    'business',
    'chic'
  ];
}

extension SexName on Sex {
  String get displayName {
    switch (this) {
      case Sex.male:
        return 'Men';
      case Sex.female:
        return 'Women';
      case Sex.unisex:
        return 'Unisex';
    }
  }

  String get databaseValue => name.toLowerCase();
}

extension SeasonName on Season {
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  String get databaseValue => name.toLowerCase();
}

extension ConditionName on Condition {
  String get displayName {
    switch (this) {
      case Condition.fair:
        return 'Fair';
      case Condition.good:
        return 'Good';
      case Condition.excellent:
        return 'Excellent';
      case Condition.as_new:
        return 'As New';
    }
  }

  String get databaseValue => name.toLowerCase();
}

// Helper functions for categories
String categoryToDisplayName(String databaseValue) {
  return databaseValue
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ')
      .replaceAll('-', ' ');
}

// Size validation functions
bool isValidTopSize(String? size) {
  if (size == null) return true;
  return ['xs', 's', 'm', 'l', 'xl', 'xxl'].contains(size.toLowerCase());
}

bool isValidShoeSize(String? size) {
  if (size == null) return true;
  final sizeNum = int.tryParse(size);
  return sizeNum != null && sizeNum >= 30 && sizeNum <= 49;
}

bool isValidBottomSize(String? size) {
  if (size == null) return true;
  final regex = RegExp(r'^W[2-4][0-9]L[2-3][0-9]$');
  return regex.hasMatch(size);
}
