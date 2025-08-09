import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../screens/product/choose_sub_product_screen.dart';

/// Main screen for choosing a product from a category
class ChooseProductScreen extends StatefulWidget {
  final String categoryId; // ID of the selected category

  const ChooseProductScreen({required this.categoryId, Key? key}) : super(key: key);

  @override
  State<ChooseProductScreen> createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Product>> _productsFuture; // Cache products fetch

  /// Arabic alphabet letters + "الكل" (All) at the end
  static const List<String> _letters = [
    'أ','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش',
    'ص','ض','ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي',
    'الكل'
  ];

  String _selectedLetter = 'الكل'; // Current selected letter filter
  List<Product> _allRootProducts = []; // Root-level products only

  /// Map for normalizing Arabic characters for filtering
  final Map<String, String> _charMap = const {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ى': 'ي'
  };

  @override
  void initState() {
    super.initState();
    // Fetch products only once when screen loads
    _productsFuture = _firebaseService.getProductsByCategory(widget.categoryId);
  }

  /// Normalize first letter for consistent comparison
  String _normalize(String s) {
    if (s.trim().isEmpty) return '';
    final first = s.trim()[0];
    return _charMap[first] ?? first;
  }

  /// Check if product matches the selected letter
  bool _matchesLetter(String name) {
    if (_selectedLetter == 'الكل') return true;
    return _normalize(name) == _normalize(_selectedLetter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top AppBar with page title and back button
      appBar: AppBar(
        title: const Text('إضافة منتج', style: TextStyle(color: Colors.green)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Error state
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }
            // No products
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
            }

            // Store root-level products only once
            if (_allRootProducts.isEmpty) {
              _allRootProducts = snapshot.data!
                  .where((p) => p.parentProduct.isEmpty)
                  .toList();
            }

            // Filter products by selected letter
            final products = _allRootProducts
                .where((p) => _matchesLetter(p.name))
                .toList();

            return ListView(
              children: [
                // Title row with add icon and back button
                _AddProductTitle(onBack: () => Navigator.pop(context)),

                // Alphabet filter bar
                _LettersBar(
                  letters: _letters,
                  selectedLetter: _selectedLetter,
                  onLetterSelected: (letter) => setState(() => _selectedLetter = letter),
                ),
                const SizedBox(height: 16),

                // Product grid or empty state
                if (products.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('لا توجد منتجات بهذا الحرف.'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true, // Fit inside ListView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      childAspectRatio: 1, // Square tiles
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        categoryId: product.id,
                        title: product.name,
                        imageUrl: product.imageUrl,
                        parentProductId: product.id,
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Title section with add product icon and back button
class _AddProductTitle extends StatelessWidget {
  final VoidCallback onBack;

  const _AddProductTitle({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic alignment
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Add icon + title text
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECF1E8), // Light green background
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 16, color: Color(0xFF2E7D32)), // Dark green icon
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'إضافة منتج',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            // Back button (always points left)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

/// Alphabet filter bar: equal-size squares except "الكل"
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
    const double letterSize = 37; // Standard letter box size
    const double allWidth = 45;   // Width for "الكل"

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
                  color: selectedLetter == letter
                      ? const Color(0xFFECF1E8) // Active background
                      : Colors.white,           // Default background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE8EBE6), // Border color
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Light shadow
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selectedLetter == letter
                        ? FontWeight.bold // Bold when active
                        : FontWeight.w500,
                    color: const Color(0xFF70756B), // Text color
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Product card inside the grid
class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String categoryId;
  final String parentProductId;

  const ProductCard({
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.parentProductId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Navigate to sub-product screen
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChooseSubProductScreen(parentProductId: parentProductId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE8EBE6), // Same border as letters
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Product image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Product title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF70756B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
