import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
/// Recipe Detail Screen — Full recipe view
/// TODO Genard: Replace dummy data with PocketBase recipe fetch
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  String? _recipeId;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_recipeId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _recipeId = args;
      } else {
        _recipeId = '1'; // Default dummy ID
      }
      
      // Simulate loading
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // Dummy recipe data — replace with real model later
  final Map<String, dynamic> _recipe = {
    'name': 'Nasi Goreng Special',
    'description':
        'Nasi goreng khas Indonesia dengan bumbu rahasia yang membuat rasanya istimewa. Cocok untuk sarapan, makan siang, atau makan malam.',
    'cookingTime': '20 min',
    'difficulty': 'Easy',
    'category': 'Makanan Utama',
    'image': null, // placeholder
    'ingredients': [
      {'name': 'Nasi putih', 'quantity': '2', 'unit': 'piring'},
      {'name': 'Telur', 'quantity': '2', 'unit': 'butir'},
      {'name': 'Bawang merah', 'quantity': '5', 'unit': 'siung'},
      {'name': 'Bawang putih', 'quantity': '3', 'unit': 'siung'},
      {'name': 'Cabai merah', 'quantity': '3', 'unit': 'buah'},
      {'name': 'Kecap manis', 'quantity': '2', 'unit': 'sdm'},
      {'name': 'Garam', 'quantity': '1', 'unit': 'sdt'},
      {'name': 'Minyak goreng', 'quantity': '3', 'unit': 'sdm'},
    ],
    'steps': [
      'Haluskan bawang merah, bawang putih, dan cabai merah.',
      'Panaskan minyak goreng di wajan dengan api sedang.',
      'Tumis bumbu halus hingga harum dan matang.',
      'Masukkan telur, aduk orak-arik hingga matang.',
      'Masukkan nasi putih, aduk rata dengan bumbu.',
      'Tambahkan kecap manis dan garam, aduk hingga merata.',
      'Masak selama 3-5 menit sambil terus diaduk.',
      'Angkat dan sajikan selagi hangat.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _recipeId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isFavorite = context.watch<FavoritesProvider>().isFavorite(_recipeId!);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar with image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  Provider.of<FavoritesProvider>(context, listen: false)
                      .toggleFavorite(_recipeId!);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Text('🍚', style: TextStyle(fontSize: 72)),
                      SizedBox(height: 8),
                      Text(
                        'Foto Resep',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name
                  Text(
                    _recipe['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),

                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Text(
                      _recipe['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Time & Difficulty row
                  Row(
                    children: [
                      _buildInfoChip(
                          Icons.access_time, _recipe['cookingTime']),
                      const SizedBox(width: 16),
                      _buildInfoChip(Icons.restaurant, _recipe['difficulty']),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Description
                  Text(
                    _recipe['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Ingredients Section
                  const Text(
                    '🧂 Bahan-bahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: List.generate(
                        (_recipe['ingredients'] as List).length,
                        (index) {
                          final ing = _recipe['ingredients'][index];
                          final isLast = index ==
                              (_recipe['ingredients'] as List).length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: AppColors.divider)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ing['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${ing['quantity']} ${ing['unit']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Steps Section
                  const Text(
                    '👨‍🍳 Langkah-langkah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  ...List.generate(
                    (_recipe['steps'] as List).length,
                    (index) => _buildStepItem(
                        index + 1, _recipe['steps'][index] as String),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                instruction,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
