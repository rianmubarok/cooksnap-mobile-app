import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/common/section_header_row.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/search/recipe_search_field.dart';

/// Maximum entries kept in the recent searches list.
const int _kMaxRecentSearches = 5;

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _recentSearchesKey = 'recent_searches';

  late final TextEditingController _controller;
  Timer? _debounce;

  List<String> _autocompleteSuggestions = [];
  List<String> _recentSearches = [];
  bool _isSuggestionsLoading = false;

  // "Populer" stays as curated list — could be fetched from analytics later.
  final List<String> _popularSearches = [
    'Rendang',
    'Sate Ayam',
    'Opor Ayam',
    'Sambal Goreng',
    'Nasi Goreng',
    'Mie Goreng',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _loadRecentSearches();

    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runSearch(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentSearchesKey);
    if (saved != null && mounted) {
      setState(() => _recentSearches = saved);
    }
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    if (mounted) setState(() => _recentSearches = []);
  }

  // ── Search logic ─────────────────────────────────────────────────────────

  /// Debounced async autocomplete — calls the repository's [searchRecipes]
  /// so PocketBase can filter server-side without loading all records.
  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      final q = query.trim();
      if (q.isEmpty) {
        setState(() {
          _autocompleteSuggestions = [];
          _isSuggestionsLoading = false;
        });
        return;
      }

      setState(() => _isSuggestionsLoading = true);

      final results = await context
          .read<RecipeRepository>()
          .searchRecipes(q, perPage: 6);

      if (!mounted) return;
      setState(() {
        _autocompleteSuggestions = results.map((r) => r.recipeName).toList();
        _isSuggestionsLoading = false;
      });
    });
  }

  void _runSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    _controller.text = q;

    // Update persistent history
    if (!_recentSearches.contains(q)) {
      setState(() {
        _recentSearches.insert(0, q);
        if (_recentSearches.length > _kMaxRecentSearches) {
          _recentSearches.removeLast();
        }
      });
      _saveRecentSearches();
    }

    Navigator.pushNamed(context, AppRoutes.searchResult, arguments: q);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        // ── Autocomplete / active search state ───────────────────────────
        if (q.isNotEmpty) ...[
          if (_isSuggestionsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.chipBackground,
                minHeight: 2,
              ),
            )
          else if (_autocompleteSuggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Tekan enter untuk mencari...',
                style: AppTextStyles.bodyMedium,
              ),
            )
          else ...[
            ..._autocompleteSuggestions.map(
              (s) => ListTile(
                leading: const Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                ),
                title: Text(s, style: AppTextStyles.bodyMedium),
                onTap: () => _runSearch(s),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],

        // ── Zero-state: history & popular ────────────────────────────────
        if (q.isEmpty) ...[
          if (_recentSearches.isNotEmpty) ...[
            SectionHeaderRow(
              title: 'Pencarian Terakhir',
              actionLabel: 'Hapus',
              onAction: _clearRecentSearches,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map(
                    (s) => AppChip(
                      label: s,
                      selected: false,
                      onTap: () => _runSearch(s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
          const Text('Pencarian Populer', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches
                .map(
                  (s) => AppChip(
                    label: s,
                    selected: false,
                    onTap: () => _runSearch(s),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
