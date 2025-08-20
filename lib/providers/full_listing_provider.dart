import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/full_listing.dart';

class FullListingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FullListing> _listings = [];

  List<FullListing> get listings => _listings;


  void setListings(List<FullListing> fullListings) {
    _listings = fullListings;
    notifyListeners();
  }
  /// 🔹 Fetch all listings
  Future<void> fetchListings() async {
    try {
      final snapshot = await _firestore.collection("listings").get();
      _listings = snapshot.docs.map((doc) {
        final data = doc.data();
        return FullListing(
          id: doc.id,
          userId: data["userId"] ?? "",
          productId: data["productId"] ?? "",
          qty: (data["qty"] ?? 0).toInt(),
          farmerName: data["farmerName"] ?? "",
          unit: data["unit"] ?? "",
          price: (data["price"] ?? 0).toDouble(),
          rating: (data["rating"] ?? 0).toDouble(),
          productName: data["productName"] ?? "",
          productImageUrl: data["productImageUrl"] ?? "",
          minimumQty: (data["minimumQty"] ?? 1).toInt(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching listings: $e");
    }
  }

  /// 🔹 Get listing by ID
  FullListing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Add new listing
  Future<void> addListing(FullListing listing) async {
    try {
      final docRef = await _firestore.collection("listings").add({
        "userId": listing.userId,
        "productId": listing.productId,
        "qty": listing.qty,
        "farmerName": listing.farmerName,
        "unit": listing.unit,
        "price": listing.price,
        "rating": listing.rating,
        "productName": listing.productName,
        "productImageUrl": listing.productImageUrl,
        "minimumQty": listing.minimumQty,
      });

      _listings.add(listing.copyWith(id: docRef.id));
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error adding listing: $e");
    }
  }

  /// 🔹 Update listing
  Future<void> updateListing(FullListing listing) async {
    try {
      await _firestore.collection("listings").doc(listing.id).update({
        "userId": listing.userId,
        "productId": listing.productId,
        "qty": listing.qty,
        "farmerName": listing.farmerName,
        "unit": listing.unit,
        "price": listing.price,
        "rating": listing.rating,
        "productName": listing.productName,
        "productImageUrl": listing.productImageUrl,
        "minimumQty": listing.minimumQty,
      });

      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = listing;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error updating listing: $e");
    }
  }

  /// 🔹 Delete listing
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection("listings").doc(id).delete();
      _listings.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error deleting listing: $e");
    }
  }
}