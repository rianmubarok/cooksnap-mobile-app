import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/recipe/recipe_list_tile.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favoriteRecipes;

    return TabPageScaffold(
      title: 'Resep Favorit',
      body: favorites.isEmpty
          ? const EmptyStateView(
              icon: Icons.favorite_border,
              title: 'Belum ada resep favorit',
              subtitle:
                  'Simpan resep kesukaanmu di sini\nagar mudah ditemukan kembali',
              showIconCircle: true,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              itemCount: favorites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingMd),
              itemBuilder: (context, index) {
                return RecipeListTile(
                  recipe: favorites[index],
                  trailing: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 22,
                  ),
                );
              },
            ),
    );
  }
}
