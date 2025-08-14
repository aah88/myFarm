import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/product_card.dart';
import '../../screens/product/choose_sub_product_screen.dart';

/// Main screen for choosing a product from a category
/// Displays a list of root-level products with filtering by Arabic letters.
/// Uses animations for smooth UI transitions.
class ChooseProductScreen extends StatefulWidget {
  final String categoryId; // ID of the selected category

  const ChooseProductScreen({required this.categoryId, Key? key})
      : super(key: key);

  @override
  State<ChooseProductScreen> createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Product>> _productsFuture; // Cache of fetched products

  /// Arabic alphabet letters + "الكل" (All) at the end
  static const List<String> _letters = [
    'أ','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش',
    'ص','ض','ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي',
    'الكل'
  ];

  String _selectedLetter = 'الكل'; // Currently selected letter for filtering
  List<Product> _allRootProducts = []; // List of root-level products

  /// Map for normalizing Arabic characters for filtering
  final Map<String, String> _charMap = const {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ى': 'ي'
  };

  @override
  void initState() {
    super.initState();
    // Fetch all products in this category when the screen loads
    _productsFuture =
        _firebaseService.getProductsByCategory(widget.categoryId);
  }

  /// Normalize first letter of the string for consistent filtering
  String _normalize(String s) {
    if (s.trim().isEmpty) return '';
    final first = s.trim()[0];
    return _charMap[first] ?? first;
  }

  /// Check if a product name matches the selected letter
  bool _matchesLetter(String name) {
    if (_selectedLetter == 'الكل') return true;
    return _normalize(name) == _normalize(_selectedLetter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top AppBar with title and back button
      appBar: AppBar(
        title: const Text('إضافة منتج',
            style: TextStyle(color: Color(0xFF2E7D32))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Main body
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // === Loading state ===
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // === Error state ===
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('حدث خطأ: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          // === Empty state ===
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
          }

          // Store root-level products (no parent) if not already cached
          if (_allRootProducts.isEmpty) {
            _allRootProducts = snapshot.data!
                .where((p) => p.parentProduct.isEmpty)
                .toList();
          }

          // Apply letter filter
          final products = _allRootProducts
              .where((p) => _matchesLetter(p.name))
              .toList();

          // Main scroll view with header, filter, and grid
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header section with title and description
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
                          color: Color(0xFF2E7D32),
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

              // Letters filter bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _LettersBar(
                    letters: _letters,
                    selectedLetter: _selectedLetter,
                    onLetterSelected: (letter) =>
                        setState(() => _selectedLetter = letter),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // AnimatedSwitcher to fade between empty and grid view
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: products.isEmpty
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
    );
  }
}

/// Widget for the alphabet filter bar
/// Displays each letter in a rounded box and highlights the selected letter
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
    const double letterSize = 37; // Box size for letters
    const double allWidth = 45; // Width for "الكل"

    return Directionality(
      textDirection: TextDirection.rtl, // Align right for Arabic
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
                  color: selectedLetter == letter
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
                        selectedLetter == letter ? FontWeight.bold : FontWeight.w500,
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

/// Widget for empty state (no products match the filter)
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

/// Responsive grid that fades in and slightly slides up each tile
class _ResponsiveFadedGrid extends StatelessWidget {
  const _ResponsiveFadedGrid({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on available width
        const double maxTileWidth = 180;
        final int crossAxisCount =
            (constraints.maxWidth / maxTileWidth).floor().clamp(2, 8);

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
            final int delayMs = 40 * (index % 8); // Stagger effect delay

            return _FadeInUp(
              delay: Duration(milliseconds: delayMs),
              child: ProductCard(
                categoryId: product.id,
                title: product.name,
                imageUrl: product.imageUrl,
                parentProductId: product.id,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseSubProductScreen(
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

/// Fade + slide-up animation for grid tiles
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
