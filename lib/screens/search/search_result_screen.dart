import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/search/recipe_search_field.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late final TextEditingController _controller;
  late List<Recipe> _results;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _results = [];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSearch(widget.query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    final repo = context.read<RecipeRepository>();
    final all = repo.getAllRecipes();
    final qLower = q.toLowerCase();
    
    setState(() {
      _results = all.where((r) {
        return r.recipeName.toLowerCase().contains(qLower) ||
            r.tags.any((t) => t.toLowerCase().contains(qLower)) ||
            r.ingredients.any(
              (i) => i.name.toLowerCase().contains(qLower),
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
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: AbsorbPointer(
                        child: RecipeSearchField(
                          controller: _controller,
                          clearable: false,
                          autofocus: false,
                          onChanged: (_) {},
                          onSubmitted: (_) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  CircularHeaderButton(
                    icon: Icons.tune_rounded,
                    onPressed: () {
                      // TODO: Implement filter sheet
                    },
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
        icon: Icons.sentiment_dissatisfied_outlined,
        title: 'Resep "$q" tidak ditemukan',
        subtitle: 'Coba kata kunci lain atau periksa ejaan',
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
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
            ),
            itemCount: _results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return RecipeCardGrid(recipe: _results[index]);
            },
          ),
        ),
      ],
    );
  }
}
