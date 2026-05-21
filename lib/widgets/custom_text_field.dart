import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

/// Reusable text input field with icon and validation
class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  /// Larger field for auth screens (18px text, taller touch target).
  final bool large;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.large = false,
  });

  static const double largeFontSize = 18;
  static const double largeMinHeight = 60;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  double get _fontSize => widget.large ? CustomTextField.largeFontSize : 15;

  double get _iconSize => widget.large ? 20 : 18;

  double get _horizontalPadding =>
      widget.large ? AppConstants.paddingScreen : AppConstants.spacingMd;

  EdgeInsets get _prefixIconPadding => EdgeInsets.only(
        left: widget.large ? 18 : 14,
        right: widget.large ? 10 : 8,
      );

  EdgeInsets get _suffixIconPadding => EdgeInsets.only(
        right: widget.large ? 14 : 10,
      );

  OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: TextStyle(
            fontSize: _fontSize,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.textHint,
              fontSize: _fontSize,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: widget.large ? 18 : AppConstants.spacingMd,
            ),
            constraints: widget.large
                ? const BoxConstraints(minHeight: CustomTextField.largeMinHeight)
                : null,
            border: _outlineBorder(AppColors.border),
            enabledBorder: _outlineBorder(AppColors.border),
            focusedBorder: _outlineBorder(AppColors.primary, width: 2),
            errorBorder: _outlineBorder(AppColors.error),
            focusedErrorBorder: _outlineBorder(AppColors.error, width: 2),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: _prefixIconPadding,
                    child: Icon(
                      widget.prefixIcon,
                      color: AppColors.textHint,
                      size: _iconSize,
                    ),
                  )
                : null,
            suffixIcon: widget.isPassword
                ? Padding(
                    padding: _suffixIconPadding,
                    child: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: _iconSize,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
