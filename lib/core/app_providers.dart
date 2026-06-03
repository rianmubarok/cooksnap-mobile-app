import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/pocketbase_recipe_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../providers/ai_detection_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/shell_navigation_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/ingredient_provider.dart';
import '../services/ai_detection_service.dart';

/// Centralised provider wiring for the app.
///
/// Each service/repository is registered once and injected into the providers
/// that depend on it — no provider instantiates its own dependencies.
///
/// ## To migrate to PocketBase:
/// Replace `DummyRecipeRepository()` with `PocketBaseRecipeRepository()`
/// in the [RecipeRepository] provider below. All downstream providers and
/// screens receive the new implementation automatically.
class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> build() {
    return [
      // ── Data layer ────────────────────────────────────────────────────────
      Provider<RecipeRepository>(
        create: (_) => PocketBaseRecipeRepository(),
      ),

      // ── Service layer ─────────────────────────────────────────────────────
      Provider<AiDetectionService>(
        create: (_) => AiDetectionService(),
      ),

      // ── State layer ───────────────────────────────────────────────────────
      ChangeNotifierProvider(
        create: (context) => FavoritesProvider(
          context.read<RecipeRepository>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => AiDetectionProvider(
          context.read<AiDetectionService>(),
        ),
      ),
      // RecommendationProvider receives the repo at construction time —
      // no more passing `repo` on every setInputs() call.
      ChangeNotifierProvider(
        create: (context) => RecommendationProvider(
          context.read<RecipeRepository>(),
        ),
      ),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ShellNavigationProvider()),
      ChangeNotifierProvider(create: (_) => PantryProvider()),
      ChangeNotifierProvider(create: (_) => IngredientProvider()),
    ];
  }
}
