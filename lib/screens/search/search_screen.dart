import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/recipe/recipe_list_tile.dart';
import '../../widgets/search/recipe_search_field.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  late List<Recipe> _results;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _results = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSearch(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    final repo = context.read<RecipeRepository>();
    final all = repo.getAllRecipes();
    final q = query.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? all
          : all.where((r) {
              return r.recipeName.toLowerCase().contains(q) ||
                  r.category.toLowerCase().contains(q) ||
                  r.ingredients.any(
                    (i) => i.name.toLowerCase().contains(q),
                  );
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingScreen,
                AppConstants.spacingMd,
                AppConstants.paddingScreen,
                AppConstants.spacingMd,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularHeaderButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: RecipeSearchField(
                      controller: _controller,
                      clearable: true,
                      autofocus: widget.initialQuery.isEmpty,
                      onChanged: _runSearch,
                      onSubmitted: _runSearch,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_results.isEmpty) {
      final q = _controller.text.trim();
      return EmptyStateView(
        icon: q.isEmpty
            ? Icons.search_rounded
            : Icons.sentiment_dissatisfied_outlined,
        title: q.isEmpty
            ? 'Ketik untuk mencari resep'
            : 'Resep "$q" tidak ditemukan',
        subtitle: q.isEmpty
            ? 'Cari berdasarkan nama, kategori, atau bahan'
            : 'Coba kata kunci lain atau periksa ejaan',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingScreen,
            0,
            AppConstants.paddingScreen,
            AppConstants.spacingSm,
          ),
          child: Text(
            '${_results.length} resep ditemukan',
            style: AppTextStyles.labelMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return RecipeListTile(recipe: _results[index]);
            },
          ),
        ),
      ],
    );
  }
}
