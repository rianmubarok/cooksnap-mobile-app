import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_chip.dart';
import '../common/app_text.dart';
import '../common/bottom_sheet_handle.dart';
import '../common/section_header_row.dart';

class SearchFilterResult {
  final String? difficulty;
  final int? maxCookingTime;

  SearchFilterResult({this.difficulty, this.maxCookingTime});
}

class SearchFilterSheet extends StatefulWidget {
  final String? initialDifficulty;
  final int? initialMaxCookingTime;

  const SearchFilterSheet({
    super.key,
    this.initialDifficulty,
    this.initialMaxCookingTime,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  String? _selectedDifficulty;
  int? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _selectedTime = widget.initialMaxCookingTime;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: AppText(title, variant: AppTextVariant.h4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingScreen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHandle(),
              SectionHeaderRow(
                title: 'Filter Pencarian',
                actionLabel: 'Reset',
                onAction: () {
                  setState(() {
                    _selectedDifficulty = null;
                    _selectedTime = null;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Kesulitan Section
              _buildSectionTitle('Tingkat Kesulitan'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Mudah', 'Sedang', 'Sulit'].map((level) {
                  return AppChip(
                    label: level,
                    selected: _selectedDifficulty == level,
                    onTap: () {
                      setState(() {
                        if (_selectedDifficulty == level) {
                          _selectedDifficulty = null; // deselect
                        } else {
                          _selectedDifficulty = level;
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // Waktu Memasak Section
              _buildSectionTitle('Waktu Memasak'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  {'label': '< 15 mnt', 'value': 15},
                  {'label': '< 30 mnt', 'value': 30},
                  {'label': '< 60 mnt', 'value': 60},
                  {'label': 'Bebas', 'value': null},
                ].map((item) {
                  final label = item['label'] as String;
                  final value = item['value'] as int?;
                  final isSelected = _selectedTime == value;
                  return AppChip(
                    label: label,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedTime = value;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXxl),

              // Actions
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      SearchFilterResult(
                        difficulty: _selectedDifficulty,
                        maxCookingTime: _selectedTime,
                      ),
                    );
                  },
                  child: const AppText(
                    'Terapkan Filter',
                    variant: AppTextVariant.buttonLarge,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}

Future<SearchFilterResult?> showSearchFilterSheet(
  BuildContext context, {
  String? initialDifficulty,
  int? initialMaxCookingTime,
}) {
  return showModalBottomSheet<SearchFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXl),
      ),
    ),
    builder: (context) => SearchFilterSheet(
      initialDifficulty: initialDifficulty,
      initialMaxCookingTime: initialMaxCookingTime,
    ),
  );
}
