import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/model/category_model.dart';
import '../data/models/product_model.dart';

class ProductController extends ChangeNotifier {
  final List<ProductsModel> _cart = [];
  final List<ProductsModel> _favorites = [];
  List<Map<String, dynamic>> _filteredProduct = [];

  // Caching and pagination state
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  DateTime? _lastFetchTime;
  bool _isInitialized = false;
  // How long cached data is considered valid
  final Duration _cacheValidityDuration = const Duration(minutes: 5);

  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  List<ProductsModel> get cart => List.unmodifiable(_cart);
  List<ProductsModel> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get allProduct => List.unmodifiable(_allProduct);
  List<Map<String, dynamic>> get filteredProduct =>
      List.unmodifiable(_filteredProduct);
  bool get isLoading => _isLoading;

  void init() {
    if (_isInitialized) return; // Prevent multiple initializations

    _isInitialized = true;

    // Load data in parallel for better performance
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        fetchProducts(),
        fetchCategories(),
        fetchAllByViewer(),
        fetchNews(),
      ]);
    } catch (error) {
      print('Error during initialization: $error');
    }
  }

  // Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
  }

  // Clear cache when needed (e.g., user logout, force refresh)
  void clearCache() {
    _cache.clear();
    _lastFetchTime = null;
  }

  // Force refresh all data
  Future<void> refreshAllData() async {
    clearCache();
    await Future.wait([
      fetchProducts(forceRefresh: true),
      fetchCategories(),
      fetchAllByViewer(),
      fetchNews(),
    ]);
  }

  List<String> imgs = [];

  Future<void> fetchNews() async {
    if (_isCacheValid() && _cache.containsKey('news')) {
      imgs = _cache['news']!.map((e) => e['image'] as String).toList();
      return;
    }

    try {
      if (!_isLoading) {
        _isLoading = true;
        notifyListeners();
      }

      var response =
          await FirebaseFirestore.instance.collection("Hot_News").get();

      // Extract images more efficiently
      imgs = response.docs
          .map((doc) => doc.data()['image'] as String?)
          .where((imageUrl) => imageUrl != null)
          .cast<String>()
          .toList();

      // Cache the results
      _cache['news'] = response.docs.map((doc) => doc.data()).toList();
      _lastFetchTime = DateTime.now();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching news: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> allByViewer = [];
  Future<void> fetchAllByViewer() async {
    if (_isCacheValid() && _cache.containsKey('allByViewer')) {
      allByViewer = List.from(_cache['allByViewer']!);
      return;
    }

    try {
      if (!_isLoading) {
        _isLoading = true;
        notifyListeners();
      }

      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .orderBy('viewer', descending: true)
          .limit(5)
          .get();

      allByViewer = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return {'id': doc.id, ...data};
      }).toList();

      // Cache the results
      _cache['allByViewer'] = List.from(allByViewer);
      _lastFetchTime = DateTime.now();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching products by viewer count: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _allProduct = [];
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _cache.containsKey('allProducts')) {
      _allProduct = List.from(_cache['allProducts']!);
      _filteredProduct = List.from(_allProduct);
      return;
    }

    try {
      if (!_isLoading) {
        _isLoading = true;
        notifyListeners();
      }

      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .limit(50) // Increased limit for better user experience
          .get();

      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      _allProduct = products;
      _filteredProduct = List.from(products);

      // Cache the results
      _cache['allProducts'] = List.from(products);
      _lastFetchTime = DateTime.now();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching all products: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    if (value.isEmpty) {
      _filteredProduct = List.from(_allProduct); // Reset to show all products
      notifyListeners();
      return;
    }

    // Perform local filtering only - no need to fetch from API
    _filteredProduct = _allProduct.where((product) {
      final name = (product['productName'] ?? '').toString().toLowerCase();
      final details =
          (product['productDetails'] ?? '').toString().toLowerCase();
      final searchTerm = value.toLowerCase();

      return name.contains(searchTerm) || details.contains(searchTerm);
    }).toList();

    notifyListeners();
  }

  // Method for server-side search if needed for large datasets
  Future<void> performServerSearch(String searchTerm) async {
    if (searchTerm.isEmpty) {
      fetchProducts();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Use Firestore query for server-side search (more efficient for large datasets)
      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .where('productName', isGreaterThanOrEqualTo: searchTerm)
          .where('productName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .limit(50)
          .get();

      _filteredProduct = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error performing server search: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CategoryModel> categories = [];
  Future<void> fetchCategories() async {
    if (_isCacheValid() && _cache.containsKey('categories')) {
      // Categories don't change often, use cached version
      return;
    }

    try {
      if (!_isLoading) {
        _isLoading = true;
        notifyListeners();
      }

      var snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
          .toList();
      categories.insert(0, CategoryModel(id: 'all', name: 'All', imageUrl: ''));

      // Cache categories
      _cache['categories'] = snapshot.docs.map((doc) => doc.data()).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backwards-compatible wrapper used by UI code expecting `fetchCG()`
  Future<void> fetchCG() async {
    await fetchCategories();
  }

  Future<void> loadFavoritesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final favDocs = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (favDocs.docs.isEmpty) {
        _favorites.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Extract all product IDs first
      final productIds =
          favDocs.docs.map((doc) => doc['productId'] as String).toList();

      // Use batch query or whereIn to fetch all products at once
      // Check if we can use whereIn (Firestore has a limit of 10 items for whereIn)
      if (productIds.length <= 10) {
        final productSnaps = await FirebaseFirestore.instance
            .collection('Product Master')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

        final loaded = productSnaps.docs
            .map((doc) => ProductsModel.fromMap(doc.id, doc.data()))
            .toList();

        _favorites
          ..clear()
          ..addAll(loaded);
      } else {
        // For more than 10 items, batch the requests
        final List<ProductsModel> loaded = [];
        for (int i = 0; i < productIds.length; i += 10) {
          final batch = productIds.skip(i).take(10).toList();
          final productSnaps = await FirebaseFirestore.instance
              .collection('Product Master')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          loaded.addAll(productSnaps.docs
              .map((doc) => ProductsModel.fromMap(doc.id, doc.data())));
        }

        _favorites
          ..clear()
          ..addAll(loaded);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
      _isLoading = false;
      notifyListeners();
    }
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
