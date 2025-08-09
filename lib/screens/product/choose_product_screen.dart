import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../screens/product/choose_sub_product_screen.dart';

class ChooseProductScreen extends StatefulWidget {
  final String categoryId;
  const ChooseProductScreen({required this.categoryId, Key? key}) : super(key: key);

  @override
  State<ChooseProductScreen> createState() => _ChooseProductScreenState();
}

class _ChooseProductScreenState extends State<ChooseProductScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Product>> _productsFuture;

  // Arabic letters + "All" at the end
  static const List<String> _letters = [
    'أ','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش',
    'ص','ض','ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي',
    'الكل'
  ];

  String _selectedLetter = 'الكل';
  List<Product> _allRootProducts = [];

  // Normalize similar Arabic letters for better matching
  final Map<String, String> _charMap = const {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ى': 'ي'
  };

  @override
  void initState() {
    super.initState();
    _productsFuture = _firebaseService.getProductsByCategory(widget.categoryId);
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد منتجات متاحة حالياً.'));
            }

            if (_allRootProducts.isEmpty) {
              _allRootProducts = snapshot.data!
                  .where((p) => p.parentProduct.isEmpty)
                  .toList();
            }

            final products = _allRootProducts
                .where((p) => _matchesLetter(p.name))
                .toList();

            // Letters bar scrolls WITH the content
            return ListView(
              children: [
                _LettersBar(
                  letters: _letters,
                  selectedLetter: _selectedLetter,
                  onLetterSelected: (letter) => setState(() => _selectedLetter = letter),
                ),
                const SizedBox(height: 16),
                if (products.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('لا توجد منتجات بهذا الحرف.'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
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

/// Equal-size square letter tiles (scrolls with content, RTL)
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
    const double tileSize = 38; // Equal width & height for every letter

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          for (final letter in letters)
            InkWell(
              onTap: () => onLetterSelected(letter),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: tileSize,
                height: tileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedLetter == letter
                      ? Colors.green.withOpacity(0.12)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedLetter == letter
                        ? Colors.green
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedLetter == letter ? Colors.green : Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
          color: Colors.transparent,
          border: Border.all(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageUrl, height: 120, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
