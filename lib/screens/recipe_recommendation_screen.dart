import 'package:flutter/material.dart';
import '../core/app_routes.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  final List<String> ingredients;

  const RecipeRecommendationScreen({super.key, required this.ingredients});

  @override
  State<RecipeRecommendationScreen> createState() =>
      _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final int recipeCount = dummyRecipes.length;
    final int ingredientCount = widget.ingredients.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Resep Rekomendasi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Text(
                    '$recipeCount resep cocok dengan $ingredientCount bahan kamu',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ingredients Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light green background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bahan yang kamu punya:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E7D32), // Darker green
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.ingredients.isEmpty
                              ? [const Text('Tidak ada bahan')]
                              : widget.ingredients.map((ingredient) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC8E6C9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFA5D6A7),
                                          width: 1),
                                    ),
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1B5E20),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Bar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune,
                              size: 18, color: Colors.black87),
                          label: const Text(
                            'Filter',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.swap_vert,
                              size: 18, color: Colors.black87),
                          label: const Text(
                            'Urutkan',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TODO Genard: replace dummy data with PocketBase + AI API call
                  // Query recipes where ingredients JSON contains any of: ingredients list
                  // Return recipes sorted by match percentage (highest first)
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = dummyRecipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildRecipeCard(recipe),
                    );
                  },
                  childCount: dummyRecipes.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(_DummyRecipe recipe) {
    final bool isAllMatch = recipe.matchPercentage == 100;
    final Color progressColor =
        isAllMatch ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    final Color textColor =
        isAllMatch ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.recipeDetail,
            arguments: recipe.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          // Image
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 40),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        recipe.time,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.restaurant,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.difficulty,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Matching text
                  if (recipe.missingText != null)
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 12, color: textColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.matchText,
                            style: TextStyle(
                                fontSize: 11,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      recipe.matchText,
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  if (recipe.missingText != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 2),
                      child: Text(
                        recipe.missingText!,
                        style: TextStyle(
                            fontSize: 10,
                            color: textColor.withOpacity(0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 4),
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: recipe.matchPercentage / 100,
                            backgroundColor: progressColor.withOpacity(0.2),
                            color: progressColor,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${recipe.matchPercentage}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Arrow Icon
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 8.0),
            child: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ),
        ],
      ),
    ),
    );
  }
}

class _DummyRecipe {
  final String id;
  final String name;
  final String time;
  final String difficulty;
  final int matchPercentage;
  final String matchText;
  final String? missingText;

  _DummyRecipe(this.id, this.name, this.time, this.difficulty,
      this.matchPercentage, this.matchText,
      [this.missingText]);
}

final List<_DummyRecipe> dummyRecipes = [
  _DummyRecipe("1", "Nasi Goreng Special", "20 min", "Easy", 100,
      "Semua bahan tersedia!"),
  _DummyRecipe("2", "Telur Dadar Bawang", "10 min", "Easy", 100,
      "Semua bahan tersedia!"),
  _DummyRecipe("3", "Nasi Telur Kecap", "15 min", "Easy", 100,
      "Semua bahan tersedia!"),
  _DummyRecipe(
      "4", "Omelette Sayur", "12 min", "Easy", 100, "Semua bahan tersedia!"),
  _DummyRecipe("5", "Mie Goreng Telur", "15 min", "Easy", 80, "Kurang 1 Bahan",
      "Sayuran Hijau"),
  _DummyRecipe("6", "Tumis Mie Sayur", "20 min", "Medium", 80, "Kurang 1 Bahan",
      "Sayuran Hijau"),
];
