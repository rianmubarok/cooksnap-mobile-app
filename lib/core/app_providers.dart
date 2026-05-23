import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/repositories/dummy_recipe_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../providers/ai_detection_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/shell_navigation_provider.dart';
import '../providers/user_provider.dart';
import '../providers/pantry_provider.dart';
import '../services/ai_detection_service.dart';

/// Centralised provider wiring for the app.
///
/// Each service/repository is registered once and injected into the providers
/// that depend on it — no provider instantiates its own dependencies.
class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> build() {
    return [
      // ── Data layer ──────────────────────────────────────────────────────
      Provider<RecipeRepository>(
        create: (_) => DummyRecipeRepository(),
      ),

      // ── Service layer ───────────────────────────────────────────────────
      Provider<AiDetectionService>(
        create: (_) => AiDetectionService(),
      ),

      // ── State layer ─────────────────────────────────────────────────────
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
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ShellNavigationProvider()),
      ChangeNotifierProvider(create: (_) => PantryProvider()),
    ];
  }
}
