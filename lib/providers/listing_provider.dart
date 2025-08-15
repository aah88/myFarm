import 'package:flutter/material.dart';
import '../models/listing_model.dart';

class ListingProvider extends ChangeNotifier {
  Listing _listing = Listing.empty();

  Listing get listing => _listing;

  void updateListing(Listing newListing) {
    _listing = newListing;
    notifyListeners();
  }

  void setCategoryId(String categoryId) { 
    _listing = _listing.copyWith(categoryId: categoryId);
    notifyListeners();
  }

  void setUserId(String userId) {
    _listing = _listing.copyWith(userId: userId);
    notifyListeners();
  }

  void setProductId(String productId) {
    _listing = _listing.copyWith(productId: productId);
    notifyListeners();
  }

  void setUnit(String unit) {
    _listing = _listing.copyWith(unit: unit);
    notifyListeners();
  }

  void setQty(int qty) {
    _listing = _listing.copyWith(qty: qty);
    notifyListeners();
  }

  void setPrice(double price) {
    _listing = _listing.copyWith(price: price);
    notifyListeners();
  }

   void setRating(double rating) {
    _listing = _listing.copyWith(price: rating);
    notifyListeners();
  }
}