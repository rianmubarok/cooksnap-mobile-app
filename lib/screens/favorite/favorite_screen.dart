import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/recipe/recipe_grid.dart';

import '../../widgets/search/recipe_search_field.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final isLoading = favProvider.isLoading;
    final allFavorites = favProvider.favoriteRecipes;
    final favorites = _searchQuery.isEmpty
        ? allFavorites
        : allFavorites
            .where((r) => r.recipeName.toLowerCase().contains(_searchQuery))
            .toList();

    return TabPageScaffold(
      title: 'Resep Favorit',
      body: Column(
        children: [
          // Search Field exactly like home screen
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
              vertical: 12,
            ),
            child: RecipeSearchField(
              controller: _searchController,
              clearable: true,
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              onChanged: (value) {
                // Also clear the search results when the user presses the 'x' button (which clears the text)
                if (value.isEmpty) {
                  setState(() {
                    _searchQuery = '';
                  });
                }
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: FavoriteScreenSkeleton(),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<FavoritesProvider>().refresh(),
                    child: favorites.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              EmptyStateView(
                                icon: LucideIcons.heart,
                                title: 'Belum ada resep favorit',
                                subtitle:
                                    'Simpan resep kesukaanmu di sini\nagar mudah ditemukan kembali',
                                showIconCircle: true,
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingScreen,
                              vertical: 8,
                            ),
                            child: RecipeGrid(
                              recipes: favorites,
                              shrinkWrap: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, recipe) =>
                                  RecipeCardGrid(recipe: recipe),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
