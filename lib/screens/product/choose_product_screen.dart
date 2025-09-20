import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../services/product_services.dart';
import '../../widgets/product_card.dart';
import '../../screens/product/choose_sub_product_screen.dart';
import '../../providers/listing_provider.dart';

// نضيف شريط التنقل السفلي فقط
import '../../widgets/bottom_nav.dart';

class ChooseProductScreen extends StatefulWidget {
  final String categoryId; // ID of the selected category

  const ChooseProductScreen({required this.categoryId, super.key});

  @override
  State<ChooseProductScreen> createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final ProductService _firebaseProductService = ProductService();
  late Future<List<Product>> _productsFuture;

  /// الحروف العربية + "الكل"
  static const List<String> _letters = [
    'أ',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'ه',
    'و',
    'ي',
    'الكل',
  ];

  String _selectedLetter = 'الكل';
  List<Product> _allRootProducts = [];

  /// لتطبيع أول حرف للمقارنة
  final Map<String, String> _charMap = const {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ى': 'ي',
  };

  @override
  void initState() {
    super.initState();
    _productsFuture = _firebaseProductService.getProductsByCategory(
      widget.categoryId,
    );
  }

  String _normalize(String s) {
    if (s.trim().isEmpty) return '';
    final first = s.trim()[0];
    return _charMap[first] ?? first;
  }

  bool _matchesLetter(String name) {
    if (_selectedLetter == 'الكل') return true;
    return _normalize(name) == _normalize(_selectedLetter);
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
                snapshot.data!.where((p) => p.parentProduct.isEmpty).toList();
          }

          final products =
              _allRootProducts.where((p) => _matchesLetter(p.name)).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر المنتج المناسب:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'استخدم الحروف لتصفية القائمة، ثم اختر المنتج للمتابعة.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // شريط الحروف
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _LettersBar(
                    letters: _letters,
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

// ====== بقية الويدجتات المساعدة كما هي ======

class _LettersBar extends StatelessWidget {
  final List<String> letters;
  final String selectedLetter;
  final ValueChanged<String> onLetterSelected;

  const _LettersBar({
    required this.letters,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    const double letterSize = 37;
    const double allWidth = 45;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final letter in letters)
            InkWell(
              onTap: () => onLetterSelected(letter),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: letter == 'الكل' ? allWidth : letterSize,
                height: letterSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedLetter == letter
                          ? const Color(0xFFECF1E8)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8EBE6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        selectedLetter == letter
                            ? FontWeight.bold
                            : FontWeight.w500,
                    color: const Color(0xFF70756B),
                  ),
                ),
              ),
            ),
        ],
      ),
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
                imageUrl: product.imageUrl,
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
