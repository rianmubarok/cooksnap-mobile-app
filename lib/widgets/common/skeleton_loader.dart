import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

// ── Shimmer animation container ───────────────────────────────────────────────

/// A single skeleton "bone" that pulses with a shimmer sweep animation.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppConstants.radiusMd,
  });

  /// Expands to fill available width.
  const SkeletonBox.fill({
    super.key,
    required this.height,
    this.borderRadius = AppConstants.radiusMd,
  }) : width = double.infinity;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _animation.value * 3, 0),
              end: Alignment(0 + _animation.value * 3, 0),
              colors: const [
                Color(0xFFE8E4DF),
                Color(0xFFF0ECE8),
                Color(0xFFE8E4DF),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ── Composed skeleton layouts ─────────────────────────────────────────────────

/// Skeleton for the home screen content area.
///
/// This widget replaces **only the content SliverToBoxAdapter** — the
/// [HomeHeader], search bar, and tag filter chips (which live in separate
/// slivers) remain visible during loading.
///
/// Pixel-accurate mirrors:
/// - [_SectionHeader]: padding fromLTRB(20, topPadding, 20, 16)
///   - "Resep Populer": topPadding=16, has "Lihat Semua" action link
///   - "Untuk Kamu":    topPadding=20, no action link
/// - [_PopularRecipesRow]: SizedBox(height: 300), horizontal ListView
/// - [RecipeCardHorizontal]: width=240, margin-right=12, full-cover Stack
/// - [RecipeGrid]: LayoutBuilder → aspectRatio = itemWidth/(itemWidth+86),
///   crossAxisCount=2, spacing=12
/// - [RecipeCardGrid]: AspectRatio(1.0) image + 10px gap + title(2 lines) +
///   6px gap + Row(2 info chips)
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── "Resep Populer" section header ─────────────────────────────
        // Mirrors _SectionHeader(title:'Resep Populer', topPadding:16, onSeeAll:...)
        // → Padding.fromLTRB(20, 16, 20, 16) wrapping SectionHeaderRow
        //   SectionHeaderRow: title (sectionTitle=18sp) + "Lihat Semua" link
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingScreen, // 20
            16,
            AppConstants.paddingScreen, // 20
            16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              // sectionTitle: fontSize=18, semibold, letterSpacing=-0.8 → ~20px tall
              SkeletonBox(
                  width: 140,
                  height: 20,
                  borderRadius: AppConstants.radiusSm),
              // "Lihat Semua" action link → ~14px tall
              SkeletonBox(
                  width: 72,
                  height: 14,
                  borderRadius: AppConstants.radiusSm),
            ],
          ),
        ),

        // ── Popular horizontal scroll ──────────────────────────────────
        // Mirrors _PopularRecipesRow: SizedBox(height: 300)
        //   ListView.builder(horizontal, padding: symmetric(horizontal:20))
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const _SkeletonHorizontalCard(),
          ),
        ),

        // ── "Untuk Kamu" section header ────────────────────────────────
        // Mirrors _SectionHeader(title:'Untuk Kamu', topPadding:20)
        // → Padding.fromLTRB(20, 20, 20, 16) wrapping only the title
        //   (no onSeeAll, so SectionHeaderRow renders no action link)
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingScreen, // 20
            20,
            AppConstants.paddingScreen, // 20
            16,
          ),
          child: SkeletonBox(
              width: 110,
              height: 20,
              borderRadius: AppConstants.radiusSm),
        ),

        // ── "Untuk Kamu" grid ──────────────────────────────────────────
        // Mirrors _RecentRecipesGrid → RecipeGrid:
        //   padding: symmetric(horizontal:20)
        //   RecipeGrid: LayoutBuilder → aspectRatio = itemWidth/(itemWidth+86)
        //   crossAxisCount=2, spacing=12 (both cross and main)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingScreen,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 12;
              const int crossAxisCount = 2;
              const double extraHeight = 86; // RecipeGrid.extraHeight default
              final double itemWidth =
                  (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                      crossAxisCount;
              final double aspectRatio = itemWidth / (itemWidth + extraHeight);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (_, __) => const _SkeletonGridCard(),
              );
            },
          ),
        ),

        const SizedBox(height: AppConstants.spacingXl),
      ],
    );
  }
}

/// Skeleton for the Recipe Detail screen.
///
/// Mirrors [RecipeDetailSliverAppBar]: SliverAppBar with expandedHeight=350,
/// plus the content body (title, info chips, description, ingredients, steps).
class RecipeDetailSkeleton extends StatelessWidget {
  const RecipeDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Mirrors SliverAppBar(expandedHeight: AppConstants.recipeImageHeight=350)
          SliverAppBar(
            expandedHeight: AppConstants.recipeImageHeight,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding:
                  const EdgeInsets.only(left: AppConstants.paddingScreen),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(
                    right: AppConstants.paddingScreen),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SkeletonBox.fill(
                height: AppConstants.recipeImageHeight,
                borderRadius: 0,
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (headlineDisplay ~28px)
                  const SkeletonBox.fill(
                      height: 28,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: 8),
                  const SkeletonBox(
                      width: 200,
                      height: 28,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Info chips row — mirrors RecipeInfoChip (clock + utensils)
                  Row(
                    children: const [
                      SkeletonBox(width: 100, height: 32),
                      SizedBox(width: AppConstants.spacingXl),
                      SkeletonBox(width: 100, height: 32),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section: Deskripsi
                  const SkeletonBox(
                      width: 90,
                      height: 18,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: AppConstants.spacingMd),
                  const SkeletonBox.fill(
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: 7),
                  const SkeletonBox.fill(
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: 7),
                  const SkeletonBox(
                      width: 220,
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: 20),

                  // Section: Bahan-bahan
                  const SkeletonBox(
                      width: 130,
                      height: 18,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: AppConstants.spacingMd),
                  ..._buildIngredientSkeletons(),
                  const SizedBox(height: 20),

                  // Section: Langkah-langkah
                  const SkeletonBox(
                      width: 150,
                      height: 18,
                      borderRadius: AppConstants.radiusSm),
                  const SizedBox(height: AppConstants.spacingMd),
                  ..._buildStepSkeletons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIngredientSkeletons() {
    final widths = [200.0, 160.0, 240.0, 180.0, 210.0];
    return List.generate(
      widths.length,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const SkeletonBox(
                width: 6, height: 6, borderRadius: 3),
            const SizedBox(width: 12),
            SkeletonBox(
                width: widths[i],
                height: 14,
                borderRadius: AppConstants.radiusSm),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStepSkeletons() {
    return List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 28, height: 28, borderRadius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox.fill(
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                  SizedBox(height: 6),
                  SkeletonBox.fill(
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                  SizedBox(height: 6),
                  SkeletonBox(
                      width: 180,
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the Search Result grid.
/// Mirrors [RecipeCardGrid] + [RecipeGrid] layout with LayoutBuilder.
class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 12;
          const int crossAxisCount = 2;
          const double extraHeight = 86;
          final double itemWidth =
              (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount;
          final double aspectRatio = itemWidth / (itemWidth + extraHeight);

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 8,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, __) => const _SkeletonGridCard(),
          );
        },
      ),
    );
  }
}

/// Skeleton for the Recipe Recommendation screen.
///
/// Mirrors [RecipeRecommendationCard]: full-width card with image (h:160) on
/// top, then title + description + progress bar below.
class RecipeRecommendationSkeleton extends StatelessWidget {
  const RecipeRecommendationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding:
              const EdgeInsets.only(left: AppConstants.paddingScreen),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E4DF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const SkeletonBox(
            width: 160, height: 20, borderRadius: AppConstants.radiusSm),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingScreen,
          AppConstants.paddingScreen,
          AppConstants.paddingScreen,
          AppConstants.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox.fill(
                height: 16, borderRadius: AppConstants.radiusSm),
            const SizedBox(height: AppConstants.spacingMd),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                SkeletonBox(
                    width: 76,
                    height: 30,
                    borderRadius: AppConstants.radiusRound),
                SkeletonBox(
                    width: 96,
                    height: 30,
                    borderRadius: AppConstants.radiusRound),
                SkeletonBox(
                    width: 66,
                    height: 30,
                    borderRadius: AppConstants.radiusRound),
                SkeletonBox(
                    width: 86,
                    height: 30,
                    borderRadius: AppConstants.radiusRound),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),

            const SkeletonBox(
                width: 100,
                height: 18,
                borderRadius: AppConstants.radiusSm),
            const SizedBox(height: 16),

            const _SkeletonRecommendationCard(),
            const _SkeletonRecommendationCard(),
            const _SkeletonRecommendationCard(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the Favorite screen grid.
/// Mirrors [RecipeCardGrid] + [RecipeGrid] with LayoutBuilder aspectRatio.
class FavoriteScreenSkeleton extends StatelessWidget {
  const FavoriteScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingScreen,
        vertical: 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 12;
          const int crossAxisCount = 2;
          const double extraHeight = 86;
          final double itemWidth =
              (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount;
          final double aspectRatio = itemWidth / (itemWidth + extraHeight);

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, __) => const _SkeletonGridCard(),
          );
        },
      ),
    );
  }
}

// ── Private building-block widgets ───────────────────────────────────────────

/// Skeleton for [RecipeCardHorizontal].
///
/// Actual card: width=240, margin-right=12, ClipRRect(radius=16) wrapping
/// Stack(fit=expand) → full-cover image + gradient at bottom + text overlay.
class _SkeletonHorizontalCard extends StatelessWidget {
  const _SkeletonHorizontalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-cover shimmer (fill entire stack)
            const SkeletonBox.fill(height: double.infinity, borderRadius: 0),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x66C8C4C0), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Title at bottom-left (AppTextVariant.h3, up to 2 lines)
            const Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox.fill(
                      height: 16, borderRadius: AppConstants.radiusSm),
                  SizedBox(height: 6),
                  SkeletonBox(
                      width: 140,
                      height: 14,
                      borderRadius: AppConstants.radiusSm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for [RecipeCardGrid].
///
/// Actual card layout:
///   Column → Stack(AspectRatio(1.0) image + favorite button) →
///   SizedBox(10) → title (up to 2 lines) → SizedBox(6) →
///   Row(RecipeInfoChip clock, SizedBox(8), RecipeInfoChip utensils)
///
/// The grid cell height is determined by RecipeGrid's LayoutBuilder formula:
/// itemHeight = itemWidth + 86, so Expanded fills the image portion correctly.
class _SkeletonGridCard extends StatelessWidget {
  const _SkeletonGridCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AspectRatio(1.0) thumbnail — Expanded fills the grid cell's image area
        Expanded(
          child: SkeletonBox.fill(
            height: double.infinity,
            borderRadius: AppConstants.radiusLg,
          ),
        ),
        const SizedBox(height: 10),
        // Title: bodyMediumSemibold (14sp), up to 2 lines
        const SkeletonBox.fill(
            height: 14, borderRadius: AppConstants.radiusSm),
        const SizedBox(height: 4),
        const SkeletonBox(
            width: 100, height: 14, borderRadius: AppConstants.radiusSm),
        const SizedBox(height: 6),
        // Info chips: RecipeInfoChip (chipHeight=36 in AppChip, but RecipeInfoChip is smaller)
        const Row(
          children: [
            SkeletonBox(
                width: 58, height: 22, borderRadius: AppConstants.radiusRound),
            SizedBox(width: 8),
            SkeletonBox(
                width: 58, height: 22, borderRadius: AppConstants.radiusRound),
          ],
        ),
      ],
    );
  }
}

/// Skeleton for [RecipeRecommendationCard].
///
/// Actual card: Container(clip, radius=16) → Column →
///   SizedBox(height:160) image +
///   Padding(16) → title(2 lines) + description(2 lines) + match row + progress bar
class _SkeletonRecommendationCard extends StatelessWidget {
  const _SkeletonRecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero image (height:160, no border radius — card clips it)
          const SkeletonBox.fill(height: 160, borderRadius: 0),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (bodyMediumSemibold, up to 2 lines)
                const SkeletonBox.fill(
                    height: 15, borderRadius: AppConstants.radiusSm),
                const SizedBox(height: 5),
                const SkeletonBox(
                    width: 180,
                    height: 15,
                    borderRadius: AppConstants.radiusSm),
                const SizedBox(height: 6),

                // Description (bodyMedium, up to 2 lines)
                const SkeletonBox.fill(
                    height: 13, borderRadius: AppConstants.radiusSm),
                const SizedBox(height: 5),
                const SkeletonBox(
                    width: 220,
                    height: 13,
                    borderRadius: AppConstants.radiusSm),
                const SizedBox(height: 12),

                // Match info row: icon + matchText + percentage
                Row(
                  children: const [
                    SkeletonBox(width: 14, height: 14, borderRadius: 7),
                    SizedBox(width: 4),
                    SkeletonBox(
                        width: 120,
                        height: 12,
                        borderRadius: AppConstants.radiusSm),
                    Spacer(),
                    SkeletonBox(
                        width: 36,
                        height: 12,
                        borderRadius: AppConstants.radiusSm),
                  ],
                ),
                const SizedBox(height: 4),

                // Progress bar (height:6, borderRadius:4)
                const SkeletonBox.fill(height: 6, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
