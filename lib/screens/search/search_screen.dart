import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../widgets/recipe/recipe_list_tile.dart';

/// Search screen — shows recipe results based on a text query.
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
        titleSpacing: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: widget.initialQuery.isEmpty,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Cari Resep',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 18),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon: _controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _controller.clear();
                  _runSearch('');
                },
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textHint, size: 20),
              )
            : null,
      ),
      onChanged: _runSearch,
      onSubmitted: _runSearch,
    );
  }

  Widget _buildBody() {
    if (_results.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingScreen,
            AppConstants.spacingMd,
            AppConstants.paddingScreen,
            AppConstants.spacingSm,
          ),
          child: Text(
            '${_results.length} resep ditemukan',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildEmptyState() {
    final q = _controller.text.trim();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            q.isEmpty ? Icons.search_rounded : Icons.sentiment_dissatisfied_outlined,
            size: 72,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            q.isEmpty ? 'Ketik untuk mencari resep' : 'Resep "$q" tidak ditemukan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            q.isEmpty
                ? 'Cari berdasarkan nama, kategori, atau bahan'
                : 'Coba kata kunci lain atau periksa ejaan',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

