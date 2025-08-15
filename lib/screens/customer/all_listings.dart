import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import '../../services/firebase_service.dart';

class ListingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;
  final String farmerName;
  final String distance;
  final VoidCallback onAddToCart;


  const ListingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
    required this.farmerName,
    required this.distance,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "المزارع: $farmerName",
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
            Text(
              "المسافة: $distance",
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
            Text(
              '$rating ⭐',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              price,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("إضافة إلى السلة"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllListingsScreen extends StatefulWidget {// ID of the selected category

  const AllListingsScreen();

  @override 
  State<AllListingsScreen> createState() => _AllListingsScreenState();
}
class _AllListingsScreenState extends State<AllListingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final String farmerImage =
      'https://cdn-icons-png.flaticon.com/512/3595/3595455.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("كل المنتجات")),
      body: Column(
        children: [
          // 🌿 Welcome Section
          Container(
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.network(farmerImage, height: 60),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'أهلاً بك!\nاختر منتجا وأضف للسلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🛒 Product Grid
          Expanded(
            child: FutureBuilder<List<FullListing>>(
              future: _firebaseService.getFullListings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد منتجات متاحة'));
                }

                final listings = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return ListingCard(
                      imageUrl: listing.productImageUrl, // replace with actual image
                      title: listing.productName,
                      rating: listing.rating, // replace with actual rating if available
                      price: listing.price,
                      farmerName: listing.farmerId,
                      distance: '5.0', // replace with actual distance müss berechnet werden
                      onAddToCart: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${listing.productName} تمت إضافته إلى السلة"),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}