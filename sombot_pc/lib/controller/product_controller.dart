import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';

class ProductController extends ChangeNotifier {
  final List<ProductsModel> _cart = [];
  final List<ProductsModel> _favorites = [];
  bool _isLoading = false;

  List<ProductsModel> get cart => List.unmodifiable(_cart);
  List<ProductsModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;

  /// 初期ロード：Firestore からお気に入り商品を読み込み
  Future<void> loadFavoritesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final favDocs = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .get();

    final List<ProductsModel> loaded = [];
    for (final doc in favDocs.docs) {
      final productId = doc['productId'];
      final productSnap = await FirebaseFirestore.instance
          .collection('Product Master')
          .doc(productId)
          .get();

      if (productSnap.exists) {
        final data = productSnap.data()!;
        loaded.add(ProductsModel.fromMap(productId, data));
      }
    }

    _favorites
      ..clear()
      ..addAll(loaded);

    _isLoading = false;
    notifyListeners();
  }

  /// お気に入りトグル（Firestoreとローカル状態を両方更新）
  Future<void> toggleFavorite(ProductsModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favQuery = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: product.id)
        .get();

    if (favQuery.docs.isNotEmpty) {
      await favQuery.docs.first.reference.delete();
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user.uid,
        'productId': product.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _favorites.add(product);
    }

    notifyListeners();
  }

  bool isInFavorites(ProductsModel product) {
    return _favorites.any((p) => p.id == product.id);
  }

  /// カート関連（ローカル操作のみ、必要ならFirestore同期可）
  void addToCart(ProductsModel product) {
    if (!_cart.any((p) => p.id == product.id)) {
      _cart.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(ProductsModel product) {
    _cart.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  bool isInCart(ProductsModel product) {
    return _cart.any((p) => p.id == product.id);
  }
}