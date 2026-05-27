import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';

enum AppTextVariant {
  headlineDisplay,
  headlineAuth,
  headlineDisplaySemibold,
  headlineLarge,
  sectionTitle,
  h3,
  h3Semibold,
  h4,
  bodyLarge,
  bodyMedium,
  bodyMediumSemibold,
  bodySmall,
  subtitleMuted,
  greeting,
  labelLarge,
  labelMedium,
  labelMediumSemibold,
  labelSmall,
  buttonLarge,
  buttonSmall,
  caption,
  link,
  emojiHero,
}

class AppText extends StatelessWidget {
  final String data;
  final AppTextVariant variant;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final Color? color;
  final double? height;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;

  /// Extra style overrides. Prefer using [variant] + small overrides only.
  final TextStyle? style;

  const AppText(
    this.data, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.color,
    this.height,
    this.fontWeight,
    this.decoration,
    this.style,
  });

  TextStyle _baseStyle() {
    switch (variant) {
      case AppTextVariant.headlineDisplay:
        return AppTextStyles.headlineDisplay;
      case AppTextVariant.headlineAuth:
        return AppTextStyles.headlineAuth;
      case AppTextVariant.headlineDisplaySemibold:
        return AppTextStyles.headlineDisplaySemibold;
      case AppTextVariant.sectionTitle:
        return AppTextStyles.sectionTitle;
      case AppTextVariant.headlineLarge:
        return AppTextStyles.headlineLarge;
      case AppTextVariant.h3:
        return AppTextStyles.h3;
      case AppTextVariant.h3Semibold:
        return AppTextStyles.h3Semibold;
      case AppTextVariant.h4:
        return AppTextStyles.h4;
      case AppTextVariant.bodyLarge:
        return AppTextStyles.bodyLarge;
      case AppTextVariant.bodyMedium:
        return AppTextStyles.bodyMedium;
      case AppTextVariant.bodyMediumSemibold:
        return AppTextStyles.bodyMediumSemibold;
      case AppTextVariant.bodySmall:
        return AppTextStyles.bodySmall;
      case AppTextVariant.subtitleMuted:
        return AppTextStyles.subtitleMuted;
      case AppTextVariant.greeting:
        return AppTextStyles.greeting;
      case AppTextVariant.labelLarge:
        return AppTextStyles.labelLarge;
      case AppTextVariant.labelMedium:
        return AppTextStyles.labelMedium;
      case AppTextVariant.labelMediumSemibold:
        return AppTextStyles.labelMediumSemibold;
      case AppTextVariant.labelSmall:
        return AppTextStyles.labelSmall;
      case AppTextVariant.buttonLarge:
        return AppTextStyles.buttonLarge;
      case AppTextVariant.buttonSmall:
        return AppTextStyles.buttonSmall;
      case AppTextVariant.caption:
        return AppTextStyles.caption;
      case AppTextVariant.link:
        return AppTextStyles.link;
      case AppTextVariant.emojiHero:
        return AppTextStyles.emojiHero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _baseStyle().copyWith(
      color: color,
      height: height,
      fontWeight: fontWeight,
      decoration: decoration,
    );

    return Text(
      data,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      style: style == null ? resolvedStyle : resolvedStyle.merge(style),
    );
  }
}

