import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../services/wikipedia_service.dart';
import '../common/bottom_sheet_handle.dart';

class IngredientWikiSheet extends StatefulWidget {
  final String ingredientName;

  const IngredientWikiSheet({super.key, required this.ingredientName});

  @override
  State<IngredientWikiSheet> createState() => _IngredientWikiSheetState();
}

class _IngredientWikiSheetState extends State<IngredientWikiSheet> {
  late Future<({String summary, String? imageUrl})?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = WikipediaService.getSummary(widget.ingredientName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingScreen),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: BottomSheetHandle()),
            Text(
              widget.ingredientName,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            FutureBuilder<({String summary, String? imageUrl})?>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || snapshot.data == null || snapshot.data!.summary.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Informasi Wikipedia tidak ditemukan untuk bahan ini.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                return Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.imageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            child: Image.network(
                              data.imageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLg),
                        ],
                        Text(
                          data.summary,
                          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                        const Row(
                          children: [
                            Icon(LucideIcons.globe, size: 14, color: AppColors.textHint),
                            SizedBox(width: 4),
                            Text(
                              'Sumber: id.wikipedia.org',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

void showIngredientWikiSheet(BuildContext context, String ingredientName) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: IngredientWikiSheet(ingredientName: ingredientName),
      ),
    ),
  );
}
