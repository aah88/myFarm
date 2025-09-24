import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../services/product_services.dart';
import '../../widgets/product_card.dart';
import '../../widgets/letters_bar.dart';
import 'choose_product_screen.dart';
import '../../providers/listing_provider.dart';

// نضيف شريط التنقل السفلي فقط
import '../../widgets/bottom_nav.dart';
import 'package:flutter_application_1/widgets/section_header.dart';

class ChooseProductScreen extends StatefulWidget {
  final String categoryId; // ID of the selected category

  const ChooseProductScreen({required this.categoryId, super.key});

  @override
  State<ChooseProductScreen> createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final ProductService _firebaseProductService = ProductService();
  late Future<List<Product>> _productsFuture;

  String _selectedLetter = defaultSelectedLetter;
  List<Product> _allRootProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _firebaseProductService.getProductsByCategory(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ليست تبويب رئيسي، فقط صفحة فرعية
      appBar: AppBar(
        title: const Text(
          'إضافة منتج',
          style: TextStyle(color: AppColors.green),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'حدث خطأ: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
          }
          if (_allRootProducts.isEmpty) {
            _allRootProducts =
                snapshot.data!.where((p) => p.parentProduct!.isEmpty).toList();
          }
          final products = filterBySelectedLetter<Product>(
            _allRootProducts,
            (p) => p.name,
            _selectedLetter,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🏷️ العنوان القابل لإعادة الاستخدام
              const SliverSectionHeader(
                title: 'اختر منتجك بسهولة:',
                subtitle:
                    'استخدم شريط الحروف لتصفية القائمة و الانتقال إلى المنتج الذي تريده بسرعة',
              ),

              // شريط الحروف
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: LettersBar(
                    selectedLetter: _selectedLetter,
                    onLetterSelected:
                        (letter) => setState(() => _selectedLetter = letter),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child:
                        products.isEmpty
                            ? const _EmptyState(key: ValueKey('empty'))
                            : _ResponsiveFadedGrid(
                              key: const ValueKey('grid'),
                              products: products,
                            ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
      // ✅ BottomNav بدون تفعيل أي تبويب
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('لا توجد منتجات بهذا الحرف.'),
      ),
    );
  }
}

class _ResponsiveFadedGrid extends StatelessWidget {
  const _ResponsiveFadedGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double maxTileWidth = 180;
        final int crossAxisCount = (constraints.maxWidth / maxTileWidth)
            .floor()
            .clamp(2, 8);

        return GridView.builder(
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
            final int delayMs = 40 * (index % 8);

            return _FadeInUp(
              delay: Duration(milliseconds: delayMs),
              child: ProductCard(
                categoryId: product.id,
                title: product.name,
                imageUrl: product.imageUrl!,
                parentProductId: product.id,
                onTap: () {
                  context.read<ListingProvider>().setProductId(product.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChooseSubProductScreen(
                            parentProductId: product.id,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _FadeInUp extends StatefulWidget {
  const _FadeInUp({
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

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
