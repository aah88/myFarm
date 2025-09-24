import 'package:flutter/material.dart';

import 'package:flutter_application_1/widgets/section_header.dart';
import 'package:flutter_application_1/widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import '../../models/category_model.dart';
import '../../providers/user_provider.dart';
import '../../services/product_services.dart';
import 'choose_product_type_screen.dart';
import '../../providers/listing_provider.dart';

// ✅ نستخدم BottomNav فقط بدون AppScaffold
import '../../widgets/bottom_nav.dart';

class ChooseCategoryScreen extends StatefulWidget {
  const ChooseCategoryScreen({super.key});

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen>
    with TickerProviderStateMixin {
  late final ProductService _firebaseProductService = ProductService();

  late Future<List<ProductCategory>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _firebaseProductService.getCategory();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureCategories = _firebaseProductService.getCategory();
    });
    await _futureCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ليست تبويب رئيسي؛ صفحة فرعية ضمن تدفق إضافة منتج
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ProductCategory>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const _LoadingSkeleton();
            } else if (snapshot.hasError) {
              content = _ErrorState(message: 'حدث خطأ: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              content = const _EmptyState();
            } else {
              final categories = snapshot.data!;
              content = _ResponsiveFadedGrid(
                categories: categories,
                onTapCategory: (cat) {
                  context.read<ListingProvider>().setCategoryId(cat.id);
                  context.read<ListingProvider>().setUserId(
                    context.read<UserProvider>().userId!,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChooseProductTypeScreen(categoryId: cat.id),
                    ),
                  );
                },
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                  //  العنوان
                const SliverSectionHeader(
                  title: 'اختر الفئة المناسبة:',
                  subtitle:'اختر فئة المنتج للمتابعة واختيار المنتج.',
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(child: content),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
      // ✅ BottomNav بدون تفعيل أي تبويب
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const double maxTileWidth = 180;
        final int crossAxisCount = (c.maxWidth / maxTileWidth).floor().clamp(
          2,
          8,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossAxisCount * 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.95,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder:
              (_, __) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F2),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('لا توجد فئات متاحة حالياً.'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
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

class _ResponsiveFadedGrid extends StatelessWidget {
  const _ResponsiveFadedGrid({
    required this.categories,
    required this.onTapCategory,
  });

  final List<ProductCategory> categories;
  final void Function(ProductCategory) onTapCategory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const double maxTileWidth = 180;
        final int crossAxisCount = (c.maxWidth / maxTileWidth).floor().clamp(
          2,
          8,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.95,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final delayMs = 40 * (index % 8);

            return _FadeInUp(
              delay: Duration(milliseconds: delayMs),
              child: CategoryCard(
                title: cat.name,
                imageUrl: cat.imageUrl,
                onTap: () => onTapCategory(cat),
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
