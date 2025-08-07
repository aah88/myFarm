import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/firebase_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();


  late Future<List<ProductCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _firebaseService.getCategory();
  }

  void _addCategory() async {
    if (_nameController.text.isNotEmpty) {
      final newCategory = ProductCategory(
        id: '',
        name: _nameController.text,
        imageUrl: _imageUrlController.text
      );

      await _firebaseService.addCategory(newCategory);
      setState(() {
        _categoriesFuture = _firebaseService.getCategory();
      });
      _nameController.clear();
      _imageUrlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الفئة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الفئة'),
            ),
              ElevatedButton(
              onPressed: _addCategory,
              child: const Text('إضافة الفئة'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'صورة'),
              keyboardType: TextInputType.url,
            ),
         
            const Divider(),

            Expanded(
              child: FutureBuilder<List<ProductCategory>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد فئة حالياً'));
                  }

                  final categories = snapshot.data!;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return ListTile(
                        title: Text(item.name),
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
