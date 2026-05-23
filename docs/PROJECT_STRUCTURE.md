# Flutter Project Structure

CookSnap uses a **layered + feature-oriented** layout to keep UI, state, and data sources separated.

```
lib/
├── core/
│   ├── api_config.dart
│   ├── app_colors.dart
│   ├── app_constants.dart
│   ├── app_decorations.dart
│   ├── app_providers.dart      # Provider tree & dependency injection
│   ├── app_routes.dart
│   ├── app_text_styles.dart
│   ├── app_theme.dart
│   └── dummy_data.dart         # Static onboarding content only
├── data/
│   ├── dummy/
│   │   ├── dummy_data.dart
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
│   ├── pantry_provider.dart
│   ├── shell_navigation_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── auth/
│   ├── favorite/
│   ├── home/
│   ├── ingredient/
│   │   ├── manual_ingredient_screen.dart
│   │   └── pantry_essentials_sheet.dart
│   ├── onboarding/
│   ├── profile/
│   ├── recipe/
│   ├── scanner/
│   │   └── widgets/
│   ├── search/
│   ├── shell/
│   │   └── main_shell_screen.dart
│   └── splash/
├── services/
│   └── ai_detection_service.dart
├── utils/
│   ├── auth_mock.dart
│   ├── ingredient_parser.dart
│   ├── placeholder_snackbar.dart
│   └── recipe_navigation.dart
├── widgets/
│   ├── auth/                   # AuthScreenLayout, AuthHeader, AuthFooterLink
│   ├── common/                 # EmptyStateView, BottomSheetHandle, etc.
│   ├── ingredient/             # Chips for ingredients
│   ├── navigation/
│   ├── profile/
│   ├── recipe/
│   ├── search/
│   ├── custom_button.dart
│   └── custom_text_field.dart
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

## Shared widgets

| Widget | Purpose |
|--------|---------|
| `TabPageScaffold` / `TabPageHeader` | Tab screens (favorit, profil, input bahan) |
| `RecipeListTile` / `RecipeCardHorizontal` | Recipe lists |
| `RecipeThumbnailBox` | Image or placeholder (`imageUrl`) |
| `RecipeSearchField` | Home + search screen |
| `EmptyStateView` | Empty lists / no results |
| `AppChip` | Category filters on home (`chipHeight`) |
| `RemovableIngredientChip` / `SuggestionChip` | Input bahan — hug-content width |
| `AuthScreenLayout` | Login & register layout |

---

## Main shell tabs

| Index | Tab | Screen |
|-------|-----|--------|
| 0 | Beranda | `HomeScreen` |
| 1 | Input Bahan | `ManualIngredientScreen` |
| 2 | Simpan | `FavoriteScreen` |
| 3 | Profil | `ProfileScreen` |

---

## Data flow example

```
Screen → context.read<RecipeRepository>()
       → DummyRecipeRepository (swap for PocketBase later)
       → Recipe model
```

---

## Next integration steps

1. Add `PocketBaseRecipeRepository` implementing `RecipeRepository`.
2. Wire `UserProvider` to PocketBase auth.
3. Replace `DummyRecipeSource` with API calls.
