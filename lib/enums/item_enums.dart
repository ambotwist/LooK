enum Size {
  xs,
  s,
  m,
  l,
  xl,
  xxl,
}

enum Season {
  spring,
  summer,
  fall,
  winter,
  any,
}

enum Gender {
  male,
  female,
  unisex,
}

enum Condition {
  fair,
  good,
  excellent,
  asNew,
}

enum HighLevelCategory {
  tops,
  bottoms,
  shoes,
  outerwear,
  accessories,
  activewear,
  underwearAndSleepwear,
  swimwear,
  formalWear,
  bags,
  jewelry,
}

enum SpecificCategory {
  // Tops
  tShirts,
  shirts,
  tankTops,
  sweaters,
  hoodies,
  blouses,
  poloShirts,

  // Bottoms
  pants,
  jeans,
  shorts,
  skirts,
  leggings,

  // Shoes
  sneakers,
  boots,
  sandals,
  flats,
  heels,
  loafers,

  // Outerwear
  jackets,
  coats,
  blazers,
  vests,

  // Accessories
  scarves,
  belts,
  gloves,
  ties,
  sunglasses,
  watches,
  jewelry,

  // Activewear
  gymTops,
  gymBottoms,
  sportsBras,
  athleticShoes,

  // Underwear & Sleepwear
  underwear,
  bras,
  pajamas,
  lingerie,
  socks,

  // Swimwear
  swimTrunks,
  bikinis,
  onePieceSwimsuits,
  rashGuards,

  // Formal Wear
  suits,
  dresses,
  tuxedos,
}

extension GenderName on Gender {
  String get displayName {
    switch (toString().split('.').last) {
      case 'male':
        return 'M';
      case 'female':
        return 'W';
      case _:
        return '-';
    }
  }
}

extension SizeName on Size {
  String get displayName {
    return toString().split('.').last.toUpperCase();
  }
}

extension ConditionName on Condition {
  String get displayName {
    switch (toString().split('.').last) {
      case 'fair':
        return 'Fair';
      case 'good':
        return 'Good';
      case 'excellent':
        return 'Excellent';
      case 'asNew':
        return 'New';
      case _:
        return '-';
    }
  }
}

extension HighCategoryName on HighLevelCategory {
  String get displayName {
    String rawName = toString().split('.').last;

    // Define exceptions for irregular plurals
    const irregularPlurals = {
      'jeans': 'Jean',
      'shorts': 'Short',
      'accessories': 'Accessory',
    };

    // Check for irregular plurals
    if (irregularPlurals.containsKey(rawName)) {
      return irregularPlurals[rawName]!;
    }

    // Singularize by removing trailing 's' (basic approach)
    if (rawName.endsWith('s')) {
      rawName = rawName.substring(0, rawName.length - 1);
    }

    // Insert spaces before capital letters, then capitalize the result
    final words = rawName.replaceAllMapped(
      RegExp(
          r'([a-z])([A-Z])'), // Matches a lowercase letter followed by an uppercase letter
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Capitalize the first letter of each word
    return words
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

extension SpecificCategoryName on SpecificCategory {
  String get displayName {
    String rawName = toString().split('.').last;

    // Define exceptions for irregular plurals
    const irregularPlurals = {
      'jeans': 'Jean',
      'shorts': 'Short',
      'accessories': 'Accessory',
    };

    // Check for irregular plurals
    if (irregularPlurals.containsKey(rawName)) {
      return irregularPlurals[rawName]!;
    }

    // Singularize by removing trailing 's' (basic approach)
    if (rawName.endsWith('s')) {
      rawName = rawName.substring(0, rawName.length - 1);
    }

    // Insert spaces before capital letters, then capitalize the result
    final words = rawName.replaceAllMapped(
      RegExp(
          r'([a-z])([A-Z])'), // Matches a lowercase letter followed by an uppercase letter
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Capitalize the first letter of each word
    return words
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
