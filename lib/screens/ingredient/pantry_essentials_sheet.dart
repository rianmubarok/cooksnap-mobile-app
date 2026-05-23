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

  @override
  void initState() {
    super.initState();
    _newIngredientController = TextEditingController();
  }

  @override
  void dispose() {
    _newIngredientController.dispose();
    super.dispose();
  }

  void _addIngredient(PantryProvider pantryProvider) {
    pantryProvider.add(_newIngredientController.text);
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
                      child: CustomTextField(
                        hintText: 'Tambah bahan dasar...',
                        large: true,
                        controller: _newIngredientController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addIngredient(pantryProvider),
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
