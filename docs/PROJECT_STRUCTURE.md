# Flutter Project Structure

CookSnap uses a **layered + feature-oriented** layout to keep UI, state, and data sources separated.

```
lib/
├── app/
│   └── app_providers.dart      # Provider tree & dependency injection
├── config/
│   └── api_config.dart         # Env-based API endpoints
├── core/
│   ├── app_colors.dart
│   ├── app_constants.dart
│   ├── app_decorations.dart
│   ├── app_routes.dart
│   ├── app_text_styles.dart
│   ├── app_theme.dart
│   └── dummy_data.dart         # Static onboarding content only
├── data/
│   ├── dummy/
│   │   └── dummy_recipe_source.dart
│   └── repositories/
│       ├── recipe_repository.dart
│       └── dummy_recipe_repository.dart
├── models/
│   ├── recipe_model.dart
│   └── scan_result_model.dart
├── providers/
│   ├── ai_detection_provider.dart
│   ├── favorites_provider.dart
│   ├── shell_navigation_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── auth/
│   ├── favorite/
│   ├── home/
│   ├── ingredient/             # Manual ingredient input tab
│   ├── onboarding/
│   ├── profile/
│   ├── recipe/
│   ├── scanner/
│   │   └── widgets/            # Scanner UI parts
│   └── splash/
├── services/
│   └── ai_detection_service.dart
├── shell/
│   └── main_shell_screen.dart  # SafeArea + bottom nav + FAB
├── utils/
│   └── ingredient_parser.dart
├── widgets/
│   ├── navigation/
│   └── recipe/
└── main.dart
```

---

## Layer responsibilities

| Layer | Role |
|-------|------|
| **presentation** | `screens/`, `widgets/`, `providers/` — UI & local state |
| **domain** | `models/`, `repositories/` (interfaces) — business entities |
| **data** | `data/dummy/`, `data/repositories/*_impl` — data sources |
| **core** | Theme, routes, shared constants |
| **services** | HTTP / third-party integrations |

---

## Main shell tabs

| Index | Tab | Screen |
|-------|-----|--------|
| 0 | Beranda | `HomeScreen` |
| 1 | Input Bahan | `ManualIngredientScreen` |
| 2 | Simpan | `FavoriteScreen` |
| 3 | Profil | `ProfileScreen` |

Tab switching: `ShellNavigationProvider.selectTab()` — used by bottom nav and Home search bar.

---

## Data flow example

```
Screen → context.read<RecipeRepository>()
       → DummyRecipeRepository (swap for PocketBase later)
       → Recipe model
```

---

## Routing

- Tab screens live inside `MainShellScreen` (not separate routes).
- Full-screen routes: splash, onboarding, auth, scanner, recipe detail, recipe recommendation.
- Pass recipe id or ingredient list via `Navigator` `arguments`.

---

## Next integration steps

1. Add `PocketBaseRecipeRepository` implementing `RecipeRepository`.
2. Wire `UserProvider` to PocketBase auth.
3. Replace `DummyRecipeSource` with API calls.
