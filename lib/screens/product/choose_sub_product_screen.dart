import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/listing_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/product_card.dart';
import '../unit/choose_unit_screen.dart';

/// Screen for choosing a *sub-product* of a given parent product.
/// - Fetches sub-products for the provided `parentProductId`.
/// - Shows a scrollable header (title + helper text).
/// - Uses a responsive grid that adapts columns to screen width.
/// - AnimatedSwitcher to transition between Loading / Empty / Grid states.
/// - Each grid tile fades in and slides up slightly (staggered).
class ChooseSubProductScreen extends StatefulWidget {
  const ChooseSubProductScreen({
    super.key,
    required this.parentProductId,
    this.firebaseService, // optional DI for tests
  });

  final String parentProductId;
  final FirebaseService? firebaseService;

  @override
  State<ChooseSubProductScreen> createState() => _ChooseSubProductScreenState();
}

class _ChooseSubProductScreenState extends State<ChooseSubProductScreen> {
  late final FirebaseService _firebaseService =
      widget.firebaseService ?? FirebaseService();

  // Cache the future so we don't refetch on every rebuild
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts =
        _firebaseService.getProductsByProductParent(widget.parentProductId);
  }

  /// Optional: Pull-to-refresh handler (re-fetch the same future)
  Future<void> _refresh() async {
    setState(() {
      _futureProducts =
          _firebaseService.getProductsByProductParent(widget.parentProductId);
    });
    await _futureProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Simple app bar
      appBar: AppBar(
        title: const Text(
          'إضافة منتج',
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // FutureBuilder drives the UI (Loading / Error / Empty / Data)
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            // Decide which *content widget* to render inside the switcher
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading: show a lightweight skeleton grid
              content = const _LoadingSkeleton();
            } else if (snapshot.hasError) {
              // Error: show message in a friendly card
              content = _ErrorState(message: 'حدث خطأ: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Empty: no sub-products found
              content = const _EmptyState();
            } else {
              // Success: build the responsive grid with fade-in tiles
              final products = snapshot.data!;
              content = _ResponsiveFadedGrid(
                products: products,
                onTapProduct: (product) {
                  // NOTE: If your listing requires the *sub-product id*, prefer product.id.
                  context.read<ListingProvider>().setProductId(product.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChooseUnitScreen()),
                  );
                },
              );
            }

            // The "page" is a CustomScrollView with a header sliver and a sliver for content.
            // The content area uses AnimatedSwitcher so transitions between states are smooth.
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header (scrolls away with the content)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Text(
                          "اختر الصنف المناسب:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 4),
                        // Helper line under the title
                        Text(
                          "اضغط على أحد المنتجات أدناه لاختيار الصنف وإكمال العملية.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Animated content area (Loading / Error / Empty / Grid)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: content,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

/// === Content states & helpers ===

/// Loading skeleton: shows grey boxes where tiles would be.
/// Gives user a hint of layout while data loads.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const double maxTileWidth = 180;
        final int crossAxisCount =
            (c.maxWidth / maxTileWidth).floor().clamp(2, 8);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossAxisCount * 4, // a few rows of placeholders
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

/// Friendly empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('empty'),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('لا توجد منتجات متاحة حالياً.'),
      ),
    );
  }
}

/// Error card with message
class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('error'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFECF1E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

/// Responsive grid that adapts to width and applies a fade-in-up animation
/// to each tile with a subtle stagger.
class _ResponsiveFadedGrid extends StatelessWidget {
  const _ResponsiveFadedGrid({
    super.key,
    required this.products,
    required this.onTapProduct,
  });

  final List<Product> products;
  final void Function(Product) onTapProduct;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Compute columns similar to SliverGridDelegateWithMaxCrossAxisExtent
        const double maxTileWidth = 180;
        final int crossAxisCount =
            (c.maxWidth / maxTileWidth).floor().clamp(2, 8);

        return GridView.builder(
          key: const ValueKey('grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final int delayMs = 40 * (index % 8); // small stagger

            return _FadeInUp(
              delay: Duration(milliseconds: delayMs),
              child: ProductCard(
                categoryId: product.category.id,
                title: product.name,
                parentProductId: product.id,
                imageUrl: product.imageUrl,
                onTap: () => onTapProduct(product),
              ),
            );
          },
        );
      },
    );
  }
}

/// Reusable fade + slight slide-up animation used for each grid tile.
class _FadeInUp extends StatefulWidget {
  const _FadeInUp({
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _opacity =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
