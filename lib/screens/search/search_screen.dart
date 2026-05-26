import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/common/section_action_link.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/search/recipe_search_field.dart';
import '../../core/app_routes.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  // Search Hub States
  List<String> _autocompleteSuggestions = [];
  
  // Mock Data for Zero-State
  final List<String> _recentSearches = ['Nasi Goreng', 'Ayam Bakar', 'Soto Ayam'];
  final List<String> _popularSearches = ['Rendang', 'Sate Ayam', 'Opor Ayam', 'Sambal Goreng'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runSearch(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _autocompleteSuggestions = []);
      return;
    }
    
    // Simulate "ajax" autocomplete by searching recipe names
    final repo = context.read<RecipeRepository>();
    final all = repo.getAllRecipes();
    final suggestions = all
        .where((r) => r.recipeName.toLowerCase().contains(q))
        .map((r) => r.recipeName)
        .take(6)
        .toList();
        
    setState(() {
      _autocompleteSuggestions = suggestions;
    });
  }

  void _runSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    // Update History
    if (!_recentSearches.contains(q)) {
      setState(() {
        _recentSearches.insert(0, q);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      });
    }

    Navigator.pushNamed(context, AppRoutes.searchResult, arguments: q);
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
                      onChanged: _onChanged,
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
    final q = _controller.text.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        0,
        AppConstants.paddingScreen,
        AppConstants.paddingScreen,
      ),
      children: [
        // Autocomplete State
        if (q.isNotEmpty) ...[
          if (_autocompleteSuggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('Tekan enter untuk mencari...', style: AppTextStyles.bodyMedium),
            )
          else ...[
            ..._autocompleteSuggestions.map((s) => ListTile(
              leading: const Icon(Icons.search, color: AppColors.textSecondary),
              title: Text(s, style: AppTextStyles.bodyMedium),
              onTap: () => _runSearch(s),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )),
            const SizedBox(height: 24),
          ],
        ],
        
        // Zero-State (History & Popular)
        if (q.isEmpty) ...[
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pencarian Terakhir', style: AppTextStyles.sectionTitle),
                SectionActionLink(
                  label: 'Hapus',
                  onTap: () => setState(() => _recentSearches.clear()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => AppChip(
                label: s,
                selected: false,
                onTap: () => _runSearch(s),
              )).toList(),
            ),
            const SizedBox(height: 32),
          ],
          const Text('Pencarian Populer', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((s) => AppChip(
              label: s,
              selected: false,
              onTap: () => _runSearch(s),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
