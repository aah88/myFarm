

class Product {
  final String id;
  final String name;
  final int price;
  final String description; 
   final String category;
  final String unit;
  final String imageUrl;
  final int farmerId;
  final int stock;

  Product({required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.unit,
    required this.imageUrl,
    required this.farmerId,
    required this.stock
    });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description']?? '',
      category: data['category']?? '',
      unit: data['unit']?? '',
      imageUrl:data['imageUrl']?? '',
      farmerId: data['farmerId']?? '',
      stock:data['stock']?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'unit': unit,
      'imageUrl': imageUrl,
      'farmerId': farmerId,
      'stock': stock,
    };
  }
}
