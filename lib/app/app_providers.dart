import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/repositories/dummy_recipe_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../providers/ai_detection_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/shell_navigation_provider.dart';
import '../providers/user_provider.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> build() {
    return [
      Provider<RecipeRepository>(
        create: (_) => DummyRecipeRepository(),
      ),
      ChangeNotifierProvider(
        create: (context) => FavoritesProvider(
          context.read<RecipeRepository>(),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AiDetectionProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ShellNavigationProvider()),
    ];
  }
}
