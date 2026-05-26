import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../utils/ingredient_resolver.dart';
import '../custom_text_field.dart';

/// Autocomplete input — pilih opsi hanya mengisi field, tidak menambah chip.
class IngredientAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;
  final ValueChanged<String>? onOptionSelected;

  const IngredientAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    this.onOptionSelected,
  });

  void _applySelection(String option) {
    controller.text = option;
    controller.selection = TextSelection.collapsed(offset: option.length);
    onOptionSelected?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) => IngredientResolver.search(value.text),
      onSelected: _applySelection,
      fieldViewBuilder: (context, fieldController, fieldFocus, onEditingComplete) {
        return CustomTextField(
          hintText: 'Ketik nama bahan...',
          large: true,
          controller: fieldController,
          focusNode: fieldFocus,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            onEditingComplete();
            onAdd();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 0,
            color: AppColors.cardBackground,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.sizeOf(context).width -
                    (AppConstants.paddingScreen * 2) -
                    50,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(option, style: AppTextStyles.bodyMedium),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
