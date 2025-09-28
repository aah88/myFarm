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

  void setUserId(String sellerId) {
    _listing = _listing.copyWith(sellerId: sellerId);
    notifyListeners();
  }

  void setProductId(String productId) {
    _listing = _listing.copyWith(productId: productId);
    notifyListeners();
  }

  void setProductName(String productName) {
    _listing = _listing.copyWith(productName: productName);
    notifyListeners();
  }

  void setSellerName(String sellerName) {
    _listing = _listing.copyWith(sellerName: sellerName);
    notifyListeners();
  }

  void setProductImageUrl(String productImageUrl) {
    _listing = _listing.copyWith(productImageUrl: productImageUrl);
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
