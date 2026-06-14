import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/offline_error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/recipe/recipe_grid.dart';
import '../../widgets/search/recipe_search_field.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late final TextEditingController _controller;

  List<Recipe> _results = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSearch(widget.query);
    });
  }

  @override
  void didUpdateWidget(covariant SearchResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
      _runSearch(widget.query);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Delegates search to the repository — PocketBase will run this server-side;
  /// dummy repo runs it in memory. Either way the UI stays identical.
  Future<void> _runSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await context
          .read<RecipeRepository>()
          .searchRecipes(q, perPage: 50);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
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
                    icon: LucideIcons.chevronLeft,
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
                    icon: LucideIcons.sliders,
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
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SearchResultSkeleton(),
      );
    }

    if (_hasError) {
      return OfflineErrorView(
        onRetry: () => _runSearch(_controller.text),
      );
    }

    if (_results.isEmpty) {
      final q = _controller.text.trim();
      return EmptyStateView(
        icon: LucideIcons.frown,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
            ),
            child: RecipeGrid(
              recipes: _results,
              padding: EdgeInsets.zero,
              itemBuilder: (context, recipe) => RecipeCardGrid(recipe: recipe),
            ),
          ),
        ),
      ],
    );
  }
}
