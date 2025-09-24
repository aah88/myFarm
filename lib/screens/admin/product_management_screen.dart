import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/product_services.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  ProductCategory? selectedCategory;
  Product? selectedProduct;
  final ProductService _firebaseProductService = ProductService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  late Future<List<Product>> _productsFuture;
  late Stream<List<ProductCategory>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _productsFuture = _firebaseProductService.getProducts();
    _categoriesStream = _firebaseProductService.categoryStream();
  }

  Future<void> _addProduct() async {
    // minimal validation: require name + category
    if (_nameController.text.trim().isEmpty || selectedCategory == null) {
      return;
    }

    final imageUrlText = _imageUrlController.text.trim();
    final String? imageUrl = imageUrlText.isEmpty ? null : imageUrlText;

    final newProduct = Product(
      id: '', // let your service assign the ID
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: selectedCategory!, // required
      parentProduct: selectedProduct?.id, // may be null
      imageUrl: imageUrl, // may be null
    );

    await _firebaseProductService.addProduct(newProduct);

    setState(() {
      _productsFuture = _firebaseProductService.getProducts();
      selectedCategory = null;
      selectedProduct = null;
    });

    _nameController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "المنتج",
                hintText: "أدخل المنتج",
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "وصف المنتج",
                hintText: "أدخل وصف المنتج",
              ),
            ),
            const SizedBox(height: 16),

            // Category picker
            StreamBuilder<List<ProductCategory>>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final categories = snapshot.data!;
                return DropdownButtonFormField<ProductCategory>(
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    hintText: "اختر من القائمة",
                  ),
                  value: selectedCategory,
                  items:
                      categories.map((cat) {
                        return DropdownMenuItem<ProductCategory>(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                  onChanged: (ProductCategory? newValue) {
                    setState(() => selectedCategory = newValue);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Parent product picker (optional)
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                // top-level products: parentProduct == null
                final products =
                    snapshot.data!
                        .where((p) => p.parentProduct == null)
                        .toList();

                return DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(
                    labelText: 'المنتج الأب (اختياري)',
                  ),
                  value: selectedProduct,
                  items:
                      products.map((prod) {
                        return DropdownMenuItem<Product>(
                          value: prod,
                          child: Text(prod.name),
                        );
                      }).toList(),
                  onChanged: (Product? newValue) {
                    setState(() => selectedProduct = newValue);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Optional image URL
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'صورة (اختياري)',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('إضافة المنتج'),
            ),
            const Divider(),

            // List of products
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات حالياً'));
                  }

                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.category.name),
                        trailing:
                            (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                ? const Icon(Icons.image)
                                : const SizedBox.shrink(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
