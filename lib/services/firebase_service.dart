import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/cart_model.dart';
import '../../models/listing_model.dart';
import '../../models/order_status.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/farmer_model.dart';
import '../../models/full_listing.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    await _db.collection('product').add(product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _db.collection('product').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection("users").doc(userId).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return AppUser.fromMap(data, userId);
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  Future<List<ProductCategory>> getCategory() async {
    final snapshot = await _db.collection('category').get();
    return snapshot.docs
        .map((doc) => ProductCategory.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Product>> productStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<ProductCategory>> categoryStream() {
    return FirebaseFirestore.instance
        .collection('category')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProductCategory.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> addCategory(ProductCategory category) async {
    await _db.collection('category').add(category.toMap());
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final querySnapshot =
        await _db
            .collection('product')
            .where('category.id', isEqualTo: categoryId)
            //.where('parent_product', isNull: false)
            .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<List<Product>> getProductsByCategoryName(String categoryName) async {
    final querySnapshot =
        await _db
            .collection('product')
            .where('category.name', isEqualTo: categoryName)
            //.where('parent_product', isNull: false)
            .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<List<Product>> getProductsByProductParent(
    String productParentId,
  ) async {
    final querySnapshot =
        await _db
            .collection('product')
            .where('parent_product', isEqualTo: productParentId)
            .get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<void> addListing(Listing listing) async {
    await _db.collection('listing').add(listing.toMap());
  }

  Future<List<Listing>> getListing() async {
    final snapshot = await _db.collection('listing').get();
    return snapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Farmer>> getFarmer() async {
    final snapshot = await _db.collection('farmer').get();
    return snapshot.docs
        .map((doc) => Farmer.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addFarmer(Farmer farmer) async {
    await _db.collection('farmer').add(farmer.toMap());
  }

  Future<void> addUser(AppUser user) async {
    await _db.collection('user').add(user.toMap());
  }

  Future<List<FullListing>> getFullListings() async {
    // 1. Get all listings
    final listingSnapshot = await _db.collection('listing').get();

    // 2. Extract all unique productIds and userIds
    final productIds =
        listingSnapshot.docs
            .map((doc) => doc['productId'] as String)
            .toSet()
            .toList();

    final userIds =
        listingSnapshot.docs
            .map((doc) => doc['userId'] as String)
            .toSet()
            .toList();

    // 3. Fetch all products in one query
    final productSnapshot =
        await _db
            .collection('product')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

    // 4. Fetch all users in one query
    final userSnapshot =
        await _db
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();

    // 5. Create quick lookup maps
    final productMap = {
      for (var doc in productSnapshot.docs) doc.id: doc.data(),
    };

    final userMap = {for (var doc in userSnapshot.docs) doc.id: doc.data()};

    // 6. Merge listing, product, and user into one object
    return listingSnapshot.docs.map((listingDoc) {
      final listingData = listingDoc.data();
      final productData = productMap[listingData['productId']] ?? {};
      final userData = userMap[listingData['userId']] ?? {};

      return FullListing.fromMap(
        listingData,
        productData,
        userData,
        listingDoc.id,
      );
    }).toList();
  }

  /// Fetch multiple listings by their IDs (for cart)
  Future<List<Listing>> getListingsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore limits whereIn queries to 10 items per query
    List<Listing> allListings = [];
    const batchSize = 10;
    for (var i = 0; i < ids.length; i += batchSize) {
      final batchIds = ids.sublist(
        i,
        (i + batchSize > ids.length) ? ids.length : i + batchSize,
      );

      final snapshot =
          await _db
              .collection('listing')
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

      allListings.addAll(
        snapshot.docs
            .map((doc) => Listing.fromMap(doc.data(), doc.id))
            .toList(),
      );
    }

    return allListings;
  }

  /// Fetch multiple listings by their IDs (for cart)
  Future<List<FullListing>> getFullListingsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore limits whereIn queries to 10 items per query
    List<FullListing> allListings = [];
    const batchSize = 10;
    for (var i = 0; i < ids.length;) {
      final batchIds = ids.sublist(
        i,
        (i + batchSize > ids.length) ? ids.length : i + batchSize,
      );

      final listingSnapshot =
          await _db
              .collection('listing')
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

      // 2. Extract all unique productIds and userIds
      final productIds =
          listingSnapshot.docs
              .map((doc) => doc['productId'] as String)
              .toSet()
              .toList();

      final userIds =
          listingSnapshot.docs
              .map((doc) => doc['userId'] as String)
              .toSet()
              .toList();

      // 3. Fetch all products in one query
      final productSnapshot =
          await _db
              .collection('product')
              .where(FieldPath.documentId, whereIn: productIds)
              .get();

      // 4. Fetch all users in one query
      final userSnapshot =
          await _db
              .collection('users')
              .where(FieldPath.documentId, whereIn: userIds)
              .get();

      // 5. Create quick lookup maps
      final productMap = {
        for (var doc in productSnapshot.docs) doc.id: doc.data(),
      };

      final userMap = {for (var doc in userSnapshot.docs) doc.id: doc.data()};

      // 6. Merge listing, product, and user into one object
      return listingSnapshot.docs.map((listingDoc) {
        final listingData = listingDoc.data();
        final productData = productMap[listingData['productId']] ?? {};
        final userData = userMap[listingData['userId']] ?? {};

        return FullListing.fromMap(
          listingData,
          productData,
          userData,
          listingDoc.id,
        );
      }).toList();
    }

    return allListings;
  }

  Future<Map<String, dynamic>?> getCartByUserId(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection("cart").doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("No cart found for this user");
        return null;
      }
    } catch (e) {
      print("Error fetching cart: $e");
      return null;
    }
  }

  Future<void> addCart(Cart cart) async {
    await _db.collection('cart').add(cart.toMap());
  }

  Future<void> createOrder(
    Cart cart,
    String selectedDelivery,
    String selectedPayment,
    OrderStatus status,
  ) async {
    // convert:
    final order = cart.toOrder(
      paymentMeanId: selectedPayment,
      deliveryMeanId: selectedDelivery,
      status: status,
    );
    await _db.collection('order').add(order.toMap());
  }

  Future<Order?> getOrderById(String id) async {
    final doc = await _db.collection('order').doc(id).get();
    if (doc.exists) {
      return Order.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('order').doc(orderId).update({'status': status.name});
  }

  Future<void> saveShopOwnerToken(String userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
      });
    }
  }
}
