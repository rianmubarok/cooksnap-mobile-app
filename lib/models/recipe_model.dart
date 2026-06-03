class RecipeIngredient {
  final String name;
  final num? quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    this.quantity,
    required this.unit,
  });

  /// Returns true when the unit is purely qualitative (e.g. "secukupnya").
  bool get isQualitative => quantity == null || quantity == 0;

  String _formatQuantity(num q) {
    if (q == q.roundToDouble()) {
      return q.toInt().toString();
    }
    
    final int whole = q.toInt();
    final num fraction = q - whole;
    
    String fractionStr = '';
    if ((fraction - 0.5).abs() < 0.01) {
      fractionStr = '1/2';
    } else if ((fraction - 0.25).abs() < 0.01) {
      fractionStr = '1/4';
    } else if ((fraction - 0.75).abs() < 0.01) {
      fractionStr = '3/4';
    } else if ((fraction - 0.33).abs() < 0.02) {
      fractionStr = '1/3';
    } else if ((fraction - 0.66).abs() < 0.02 || (fraction - 0.67).abs() < 0.02) {
      fractionStr = '2/3';
    } else {
      // Fallback for non-standard decimals, remove trailing zeros
      return q.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
    }
    
    if (whole == 0) return fractionStr;
    return '$whole $fractionStr';
  }

  /// Returns the display string for the amount column.
  String get amountLabel {
    if (isQualitative) return unit;
    return '${_formatQuantity(quantity!)} $unit';
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      quantity: map['quantity'] as num?,
      unit: map['unit'] as String,
    );
  }
}

class Recipe {
  final String id;
  final String recipeName;
  final String description;
  final String? imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final int cookingTime;
  final String difficulty;
  final List<String> tags;
  final String? sourceUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  const Recipe({
    required this.id,
    required this.recipeName,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.difficulty,
    required this.tags,
    this.sourceUrl,
    this.videoUrl,
    this.createdAt,
  });

  String get cookingTimeLabel {
    if (cookingTime < 60) return '$cookingTime mnt';
    final int hours = cookingTime ~/ 60;
    final int mins = cookingTime % 60;
    if (mins == 0) return '$hours jam';
    return '$hours jam $mins mnt';
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    final rawIngredients = map['ingredients'];
    final parsedIngredients = <RecipeIngredient>[];
    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item is Map<String, dynamic>) {
          parsedIngredients.add(
            RecipeIngredient(
              name: (item['name'] ?? '').toString(),
              quantity: (item['quantity'] is num) ? item['quantity'] as num : null,
              unit: (item['unit'] ?? 'pcs').toString(),
            ),
          );
        } else if (item != null) {
          parsedIngredients.add(
            RecipeIngredient(
              name: item.toString(),
              quantity: 1,
              unit: 'pcs',
            ),
          );
        }
      }
    }

    final rawTags = map['tags'];
    final parsedTags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];

    final rawSteps = map['steps'];
    final parsedSteps = rawSteps is List
        ? rawSteps.map((e) => e.toString()).toList()
        : <String>[];

    return Recipe(
      id: map['id'] as String,
      recipeName: map['recipe_name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String?,
      ingredients: parsedIngredients,
      steps: parsedSteps,
      cookingTime: map['cooking_time'] is int
          ? map['cooking_time'] as int
          : int.tryParse('${map['cooking_time']}') ?? 0,
      difficulty: map['difficulty'] as String,
      tags: parsedTags,
      sourceUrl: map['source_url'] as String?,
      videoUrl: map['video_url'] as String?,
      createdAt: (map['created_at'] ?? map['created']) != null 
          ? DateTime.tryParse((map['created_at'] ?? map['created']).toString()) 
          : null,
    );
  }
}

class RecipeRecommendation {
  final Recipe recipe;
  final int matchPercentage;
  final String matchText;
  final String? missingIngredientName;
  final int matchedCount;
  final int partialMatchedCount;

  const RecipeRecommendation({
    required this.recipe,
    required this.matchPercentage,
    required this.matchText,
    this.missingIngredientName,
    this.matchedCount = 0,
    this.partialMatchedCount = 0,
  });

  bool get isFullMatch => matchPercentage >= 100;
}
