import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../providers/pantry_provider.dart';
import '../../widgets/common/bottom_sheet_handle.dart';
import '../../widgets/common/section_action_link.dart';
import '../../widgets/common/square_icon_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/ingredient/removable_ingredient_chip.dart';
import '../../data/dummy/dummy_ingredients.dart';
import '../../utils/string_utils.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bahan "$value" sudah ada atau mirip dengan "$existing".'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingScreen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHandle(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pantry Essentials',
                      style: AppTextStyles.sectionTitle,
                    ),
                    SectionActionLink(
                      label: 'Reset Default',
                      onTap: pantryProvider.resetToDefault,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Bahan-bahan di bawah ini diasumsikan selalu tersedia di dapurmu.',
                  style: AppTextStyles.bodySmall.copyWith(height: 1.5),
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
                          return DummyIngredients.items.where((String option) {
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
                      onPressed: () => _addIngredient(pantryProvider),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Wrap(
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
                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }
}
