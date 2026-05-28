class RecipeIngredient {
  final String name;
  final num quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      quantity: map['quantity'] as num,
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

  String get cookingTimeLabel => '$cookingTime min';

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      recipeName: map['recipe_name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String?,
      ingredients: (map['ingredients'] as List)
          .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(map['steps'] as List),
      cookingTime: map['cooking_time'] as int,
      difficulty: map['difficulty'] as String,
      tags: List<String>.from(map['tags'] as List),
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
