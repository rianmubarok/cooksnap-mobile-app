import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/recipe/recipe_card_grid.dart';

import '../../widgets/search/recipe_search_field.dart';
import '../../core/app_routes.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favoriteRecipes;

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
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.search,
                  arguments: '',
                );
              },
              child: const AbsorbPointer(
                child: RecipeSearchField(),
              ),
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const EmptyStateView(
                    icon: LucideIcons.heart,
                    title: 'Belum ada resep favorit',
                    subtitle:
                        'Simpan resep kesukaanmu di sini\nagar mudah ditemukan kembali',
                    showIconCircle: true,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingScreen,
                      vertical: 8,
                    ),
                    itemCount: favorites.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      return RecipeCardGrid(recipe: favorites[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
