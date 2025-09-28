import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/listing_model.dart';
import '../../models/full_listing.dart';

class ListingService {
  final _db = FirebaseFirestore.instance;

  Future<void> addListing(Listing listing) async {
    await _db.collection('listing').add(listing.toMap());
  }

  Future<List<Listing>> getActiveListing() async {
    final listingSnapshot =
        await _db.collection('listing').where('active', isEqualTo: true).get();
    return listingSnapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Listing>> getInactiveListing() async {
    final listingSnapshot =
        await _db.collection('listing').where('active', isEqualTo: false).get();
    return listingSnapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Listing>> getAllListing() async {
    final listingSnapshot = await _db.collection('listing').get();
    return listingSnapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Listing>> getListingByCategoryId(String categoryId) async {
    final listingSnapshot =
        await _db
            .collection('listing')
            .where('categoryId', isEqualTo: categoryId)
            .where('active', isEqualTo: false)
            .get();
    return listingSnapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Listing>> getListingBySellerId(String sellerId) async {
    final listingSnapshot =
        await _db
            .collection('listing')
            .where('sellerId', isEqualTo: sellerId)
            .where('active', isEqualTo: false)
            .get();
    return listingSnapshot.docs
        .map((doc) => Listing.fromMap(doc.data(), doc.id))
        .toList();
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

  Future<void> finalizeSingleListing({
    required String listingId,
    required int qtyToBuy,
  }) async {
    if (qtyToBuy <= 0) throw ArgumentError('qtyToBuy must be > 0');

    final ref = _db.collection('listing').doc(listingId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw StateError('Listing not found: $listingId');
      }

      final data = snap.data() as Map<String, dynamic>;
      final bool active = (data['active'] as bool?) ?? true;
      final int available = (data['qty'] as int?) ?? 0;
      final int minimumQty = (data['minimumQty'] as int?) ?? 0;

      if (!active) {
        throw StateError('Listing is inactive');
      }

      final int remaining = available - qtyToBuy;
      bool stillActive = active;
      if (remaining < 0) {
        throw StateError(
          'Not enough quantity. Have $available, need $qtyToBuy.',
        );
      }
      if (remaining == 0) {
        stillActive = false;
      }
      // if (remaining < minimumQty) {
      //   stillActive = false;
      //   throw StateError(
      //     'Remaining qty ($remaining) would be below minimum ($minimumQty).',
      //   );
      // }

      tx.update(ref, {'qty': remaining, 'active': stillActive});
    });
  }

  Future<List<FullListing>> getFullListings() async {
    // 1. Get all listings
    final listingSnapshot =
        await _db.collection('listing').where('active', isEqualTo: true).get();

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

  Future<List<FullListing>> getFarmerFullListings(String farmerId) async {
    final listingSnapshot =
        await _db
            .collection('listing')
            .where('userId', isEqualTo: farmerId)
            .get();
    final productIds =
        listingSnapshot.docs
            .map((doc) => doc['productId'] as String)
            .toSet()
            .toList();
    final userSnapshot =
        await _db
            .collection('users')
            .where(FieldPath.documentId, isEqualTo: farmerId)
            .get();

    // 3. Fetch all products in one query
    final productSnapshot =
        await _db
            .collection('product')
            .where(FieldPath.documentId, whereIn: productIds)
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
      final userData = userMap[farmerId] ?? {};

      return FullListing.fromMap(
        listingData,
        productData,
        userData,
        listingDoc.id,
      );
    }).toList();
  }

  Future<List<FullListing>> getFullListingsByCategory(String categoryId) async {
    // 1. Get all listings

    final listingSnapshot =
        await _db
            .collection('listing')
            .where('categoryId', isEqualTo: categoryId)
            .where('active', isEqualTo: true)
            .get();
    if (listingSnapshot.docs.isEmpty) {
      return const <FullListing>[];
    }
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
}
