import 'package:flutter/material.dart';
import '../custom_text_field.dart';

/// Search input — uses the same [CustomTextField] styling as ingredient input.
class RecipeSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool clearable;

  const RecipeSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.clearable = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'Cari Resep',
      prefixIcon: Icons.search_rounded,
      large: true,
      clearable: clearable,
      controller: controller,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
