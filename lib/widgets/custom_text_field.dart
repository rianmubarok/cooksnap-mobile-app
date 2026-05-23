import 'dart:async';
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
  final ValueChanged<String>? onChanged;
  /// Larger field for auth screens (18px text, taller touch target).
  final bool large;
  /// Shows a clear button when the field has text (e.g. search).
  final bool clearable;
  final bool autofocus;
  final double? iconSize;
  final List<String>? animatedHints;

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
    this.onChanged,
    this.large = false,
    this.clearable = false,
    this.autofocus = false,
    this.iconSize,
    this.animatedHints,
  });

  static const double largeFontSize = 18;
  static const double largeMinHeight = 60;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  int _currentHintIndex = 0;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    _startHintTimerIfNeeded();
  }

  void _startHintTimerIfNeeded() {
    if (widget.animatedHints != null && widget.animatedHints!.isNotEmpty) {
      _hintTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            _currentHintIndex = (_currentHintIndex + 1) % widget.animatedHints!.length;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (widget.clearable || widget.animatedHints != null) setState(() {});
    }
    if (oldWidget.animatedHints != widget.animatedHints) {
      _hintTimer?.cancel();
      _startHintTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.clearable || widget.animatedHints != null) setState(() {});
  }

  double get _fontSize => widget.large ? CustomTextField.largeFontSize : 15;

  double get _iconSize => widget.iconSize ?? (widget.large ? 20 : 18);

  double get _horizontalPadding =>
      widget.large ? AppConstants.paddingScreen : AppConstants.spacingMd;

  EdgeInsets get _prefixIconPadding => EdgeInsets.only(
        left: widget.large ? 18 : 14,
        right: widget.large ? 10 : 8,
      );

  EdgeInsets get _suffixIconPadding => EdgeInsets.only(
        right: widget.large ? 14 : 10,
      );

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return Padding(
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
      );
    }

    if (widget.clearable &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      return Padding(
        padding: _suffixIconPadding,
        child: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textHint, size: _iconSize),
          onPressed: () {
            widget.controller!.clear();
            widget.onChanged?.call('');
          },
        ),
      );
    }

    return null;
  }

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
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        TextFormField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: TextStyle(
            fontSize: _fontSize,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            label: widget.animatedHints != null
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == ValueKey<int>(_currentHintIndex);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.0, isIncoming ? 0.3 : -0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      widget.animatedHints![_currentHintIndex],
                      key: ValueKey<int>(_currentHintIndex),
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: _fontSize,
                      ),
                    ),
                  )
                : null,
            floatingLabelBehavior: widget.animatedHints != null
                ? FloatingLabelBehavior.never
                : null,
            hintText: widget.animatedHints != null ? null : widget.hintText,
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
            suffixIcon: _buildSuffixIcon(),
          ),
        ),
      ],
    );
  }
}

