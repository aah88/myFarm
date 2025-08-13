import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/listing_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/product_card.dart';
import '../unit/choose_unit_screen.dart';

class ChooseSubProductScreen extends StatefulWidget {
  const ChooseSubProductScreen({
    super.key,
    required this.parentProductId,
    this.firebaseService, // allow DI for testing, else a default is used
  });

  final String parentProductId;
  final FirebaseService? firebaseService;

  @override
  State<ChooseSubProductScreen> createState() => _ChooseSubProductScreenState();
}

class _ChooseSubProductScreenState extends State<ChooseSubProductScreen> {
  late final FirebaseService _firebaseService =
      widget.firebaseService ?? FirebaseService();

  late Future<List<Product>> _futureProducts; // cache the future

  @override
  void initState() {
    super.initState();
    _futureProducts =
        _firebaseService.getProductsByProductParent(widget.parentProductId);
  }

  // Optional: pull-to-refresh to re-fetch if needed
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
      appBar: AppBar(
        // App bar with consistent brand color usage
        title: const Text(
          'إضافة منتج',
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
        leading: IconButton(
          // Back button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Body uses FutureBuilder to fetch sub-products ONCE (cached in state)
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
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
                child: Text(
                  'حدث خطأ: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }

          // === Empty state ===
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('لا توجد منتجات متاحة حالياً.'),
              ),
            );
          }

          // === Success state ===
          final products = snapshot.data!;

          // Wrap in RefreshIndicator (optional quality-of-life)
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    // Header (scrolls away with content)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                // Responsive grid using MaxCrossAxisExtent
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180, // responsive columns
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];

                        return KeyedSubtree(
                          key: ValueKey(product.id), // stable identity
                          child: ProductCard(
                            categoryId: product.category.id,
                            title: product.name,
                            parentProductId: product.id,
                            imageUrl: product.imageUrl,
                            onTap: () {
                              // NOTE: إن كانت عملية النشر تتطلب subProductId فعليًا،
                              // فالأدق تمرير product.id بدل product.category.id
                              context
                                  .read<ListingProvider>()
                                  .setProductId(product.category.id);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChooseUnitScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
