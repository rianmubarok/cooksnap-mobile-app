import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../providers/pantry_provider.dart';
import '../../widgets/common/bottom_sheet_handle.dart';
import '../../widgets/common/section_header_row.dart';
import '../../widgets/common/square_icon_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/ingredient/removable_ingredient_chip.dart';
import '../../providers/ingredient_provider.dart';
import '../../utils/string_utils.dart';
import '../../utils/app_snackbar.dart';

void showPantryEssentialsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXl),
      ),
    ),
    builder: (sheetContext) => const PantryEssentialsSheet(),
  );
}

/// Pantry bottom sheet — controller lifecycle owned by [State].
class PantryEssentialsSheet extends StatefulWidget {
  const PantryEssentialsSheet({super.key});

  @override
  State<PantryEssentialsSheet> createState() => _PantryEssentialsSheetState();
}

class _PantryEssentialsSheetState extends State<PantryEssentialsSheet> {
  late final TextEditingController _newIngredientController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _newIngredientController = TextEditingController();
  }

  @override
  void dispose() {
    _newIngredientController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(PantryProvider pantryProvider, [String? valueOverride]) {
    final value = valueOverride ?? _newIngredientController.text.trim();
    if (value.isEmpty) return;

    for (var existing in pantryProvider.items) {
      if (StringUtils.isSimilar(existing, value)) {
        showAppSnackBar(
          context,
          'Bahan "$value" sudah ada atau mirip dengan "$existing".',
          variant: AppSnackBarVariant.error,
        );
        _newIngredientController.clear();
        return;
      }
    }

    pantryProvider.add(value);
    _newIngredientController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Consumer<PantryProvider>(
        builder: (context, pantryProvider, child) {
          final essentials = pantryProvider.items;
          final isActive  = pantryProvider.isPantryActive;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingScreen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHandle(),
                SectionHeaderRow(
                  title: AppStrings.pantryEssentialsTitle,
                  actionLabel: AppStrings.resetToDefault,
                  onAction: pantryProvider.resetToDefault,
                ),
                const SizedBox(height: AppConstants.spacingSm),

                // ── Global Toggle ─────────────────────────────────────────
                GestureDetector(
                  onTap: pantryProvider.togglePantryActive,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryDark.withValues(alpha: 0.08)
                          : AppColors.border.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primaryDark.withValues(alpha: 0.25)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isActive
                                    ? 'Bahan dasar aktif'
                                    : 'Bahan dasar tidak aktif',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppColors.primaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isActive
                                    ? 'Bahan-bahan ini diasumsikan selalu tersedia dan ikut disertakan saat mencari resep.'
                                    : 'Bahan-bahan ini diabaikan saat mencari resep.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: isActive,
                          onChanged: (_) => pantryProvider.togglePantryActive(),
                          activeThumbColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: RawAutocomplete<String>(
                        textEditingController: _newIngredientController,
                        focusNode: _focusNode,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          final allItems = context.read<IngredientProvider>().items;
                          return allItems.where((String option) {
                            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _addIngredient(pantryProvider, selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          return CustomTextField(
                            hintText: 'Tambah bahan dasar...',
                            large: true,
                            controller: controller,
                            focusNode: focusNode,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              onEditingComplete();
                              _addIngredient(pantryProvider);
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 0.0,
                              color: AppColors.cardBackground,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: MediaQuery.of(context).size.width - (AppConstants.paddingScreen * 2) - 50,
                                ),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(option, style: AppTextStyles.bodyMedium),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    SquareIconButton(
                      size: 52,
                      onPressed: () => _addIngredient(pantryProvider),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // ── Ingredient chips (dimmed when pantry is off) ──────────
                AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 200),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: essentials
                        .map(
                          (item) => RemovableIngredientChip(
                            label: item,
                            onRemove: () => pantryProvider.remove(item),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }
}

