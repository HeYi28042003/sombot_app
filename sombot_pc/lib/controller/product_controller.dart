import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });
}

class ProductController extends ChangeNotifier {
  final List<Product> _cart = [];
  final List<Product> _favorites = [];

  List<Product> get cart => List.unmodifiable(_cart);
  List<Product> get favorites => List.unmodifiable(_favorites);

  void addToCart(Product product) {
    if (!_cart.any((p) => p.id == product.id)) {
      _cart.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  void addToFavorites(Product product) {
    if (!_favorites.any((p) => p.id == product.id)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(Product product) {
    _favorites.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _cart.any((p) => p.id == product.id);
  }

  bool isInFavorites(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }
}