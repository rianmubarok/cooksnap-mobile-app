import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/placeholder_snackbar.dart';
import '../../widgets/common/offline_error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/recipe/recipe_detail_sliver_app_bar.dart';
import '../../widgets/recipe/recipe_info_chip.dart';
import '../../widgets/recipe/recipe_ingredients_section.dart';
import '../../widgets/recipe/recipe_steps_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  static ({String id, List<String> ingredients}) _parseArgs(Object? args) {
    if (args is String) return (id: args, ingredients: []);
    if (args is Map) {
      return (
        id: args['id'] as String,
        ingredients: (args['availableIngredients'] as List<String>?) ?? [],
      );
    }
    return (id: '1', ingredients: []);
  }

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  /// Stored once so the Future isn't recreated on every rebuild.
  Future<Recipe?>? _recipeFuture;
  List<String> _availableIngredients = [];
  String? _recipeId;
  bool _isTogglingFavorite = false;
  bool _hasError = false;

  void _loadRecipe() {
    if (_recipeId == null) return;
    setState(() => _hasError = false);
    _recipeFuture =
        context.read<RecipeRepository>().getRecipeById(_recipeId!).catchError(
      (e) {
        if (mounted) setState(() => _hasError = true);
        return null as Recipe?;
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Parse route args exactly once.
    if (_recipeId == null) {
      final parsed =
          RecipeDetailScreen._parseArgs(ModalRoute.of(context)?.settings.arguments);
      _recipeId = parsed.id;
      _availableIngredients = parsed.ingredients;
      _loadRecipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe?>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const RecipeDetailSkeleton();
        }

        // ── Error (offline / network) ──────────────────────────────────
        if (_hasError || snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: OfflineErrorView(onRetry: _loadRecipe),
          );
        }

        // ── Not found ────────────────────────────────────────────────────
        final recipe = snapshot.data;
        if (recipe == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            body: const Center(child: Text('Resep tidak ditemukan')),
          );
        }

        // ── Found ────────────────────────────────────────────────────────
        final isFavorite =
            context.watch<FavoritesProvider>().isFavorite(recipe.id);
        
        final pantryItems = context.watch<PantryProvider>().items;
        final allAvailableIngredients = _availableIngredients.isNotEmpty
            ? [..._availableIngredients, ...pantryItems]
            : <String>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              RecipeDetailSliverAppBar(
                recipe: recipe,
                isFavorite: isFavorite,
                onBack: () => Navigator.pop(context),
                onToggleFavorite: () async {
                  if (_isTogglingFavorite) return;
                  setState(() {
                    _isTogglingFavorite = true;
                  });

                  final favoritesProvider = context.read<FavoritesProvider>();
                  final willBeFavorite = !favoritesProvider.isFavorite(recipe.id);
                  try {
                    await favoritesProvider.toggleFavorite(recipe.id);
                    if (context.mounted) {
                      showAppSnackBar(
                        context,
                        willBeFavorite
                            ? 'Resep ditambahkan ke favorit'
                            : 'Resep dihapus dari favorit',
                        variant: AppSnackBarVariant.success,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showAppSnackBar(
                        context,
                        'Gagal memperbarui favorit: ${e.toString()}',
                        variant: AppSnackBarVariant.error,
                        duration: const Duration(seconds: 4),
                      );
                    }
                  } finally {
                    if (context.mounted) {
                      setState(() {
                        _isTogglingFavorite = false;
                      });
                    }
                  }
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingScreen),
                  child: _RecipeDetailBody(
                    recipe: recipe,
                    availableIngredients: allAvailableIngredients,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Detail body ─────────────────────────────────────────────────────────────

class _RecipeDetailBody extends StatelessWidget {
  final Recipe recipe;
  final List<String> availableIngredients;

  const _RecipeDetailBody({
    required this.recipe,
    required this.availableIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.recipeName, style: AppTextStyles.headlineDisplay),
        const SizedBox(height: AppConstants.spacingMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              RecipeInfoChip(
                icon: LucideIcons.clock,
                text: recipe.cookingTimeLabel,
              ),
              const SizedBox(width: AppConstants.spacingXl),
              RecipeInfoChip(
                icon: LucideIcons.utensils,
                text: recipe.difficulty,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Deskripsi', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          recipe.description,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.grey666,
          ),
        ),
        const SizedBox(height: 20),
        RecipeIngredientsSection(
          ingredients: recipe.ingredients,
          availableIngredients: availableIngredients,
        ),
        const SizedBox(height: 20),
        RecipeStepsSection(steps: recipe.steps),
        if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Sumber', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppConstants.spacingMd),
          _SourceLink(url: recipe.sourceUrl!),
        ],
        if (recipe.videoUrl != null && recipe.videoUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Lihat Video',
            icon: LucideIcons.playCircle,
            useGradient: true,
            onPressed: () => showPlaceholderSnackBar(
              context,
              'Pemutaran video segera hadir',
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
        ],
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  final String url;

  const _SourceLink({required this.url});

  String get _displayLabel {
    final host = Uri.tryParse(url)?.host;
    if (host != null && host.isNotEmpty) {
      return host.replaceFirst('www.', '');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              showAppSnackBar(
                context,
                'Gagal membuka sumber',
                variant: AppSnackBarVariant.error,
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.link, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                _displayLabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
