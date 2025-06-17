import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/product_controller.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/router/app_route.dart';
import 'package:sombot_pc/utils/colors.dart';
import 'package:sombot_pc/utils/text_style.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({required this.id, required this.name, required this.imageUrl});

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['categoryName'] ?? '',
      imageUrl: data['imageBase64'] ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  bool _isCategoryLoading = true;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categoryProducts = [];
  bool _isCategoryProductsLoading = false;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchCategories();
    Provider.of<ProductController>(context, listen: false).loadFavoritesFromFirestore();
  }

  Future<void> fetchOrders() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('Product Master').get();
      List<Map<String, dynamic>> orders = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('categories').get();
      List<CategoryModel> categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
          .toList();
      categories.insert(0, CategoryModel(id: 'all', name: 'All', imageUrl: ''));
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  Future<void> fetchCategoryProducts(String categoryId) async {
    setState(() {
      _isCategoryProductsLoading = true;
      _selectedCategoryId = categoryId;
    });
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .where('category', isEqualTo: categoryId)
          .get();
      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        final data = doc.data();
       if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return {'id': doc.id, ...data};
      }).toList();
      setState(() {
        _categoryProducts = products;
        _isCategoryProductsLoading = false;
      });
    } catch (e) {
      print('Error fetching category products: $e');
      setState(() {
        _isCategoryProductsLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final loc = AppLocalizations.of(context)!;
    final productController = Provider.of<ProductController>(context);
    final filteredOrders = _searchQuery.isEmpty
        ? _orders
        : _orders.where((product) {
            final name = (product['productName'] ?? '').toString().toLowerCase();
            final details = (product['productDetails'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || details.contains(_searchQuery);
          }).toList();

    final displayList = _selectedCategoryId == null
        ? filteredOrders
        : _categoryProducts;

    final isLoading = _selectedCategoryId == null
        ? _isLoading
        : _isCategoryProductsLoading;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 10),
            if (_searchQuery.isEmpty) _buildCategoryList(),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildGrid(displayList, loc, productController, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return _isCategoryLoading
        ? const CircularProgressIndicator()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((e) {
                return InkWell(
                  onTap: () {
                    if (e.id == 'all') {
                      setState(() {
                        _selectedCategoryId = null;
                        _categoryProducts = [];
                      });
                    } else {
                      fetchCategoryProducts(e.id);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedCategoryId == e.id ||
                                (_selectedCategoryId == null && e.id == 'all')
                            ? AppColors.primary
                            : AppColors.darkGrey,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          e.imageUrl.isNotEmpty
                              ? Image.memory(
                                  base64Decode(e.imageUrl),
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(width: 20, height: 35),
                          const SizedBox(width: 10),
                          Text(e.name,
                              style: e.imageUrl.isNotEmpty
                                  ? normal
                                  : normal.copyWith(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }

  Widget _buildGrid(List<Map<String, dynamic>> products, AppLocalizations loc, ProductController controller,var screenWidth) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
         double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth > 400 ?  0.7 : 0.58; // Adjust aspect ratio based on screen width
        return  GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final productModel = ProductsModel.fromMap(
            product['id'],
            product,
          );
          final isFavorite = controller.isInFavorites(productModel);
      
          return InkWell(
            onTap: () => context.router.push(DetailRoute(productModel: productModel)),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.blue[200] : Colors.pink[200],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(product['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 95,
                              child: Text(
                                product['productName'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: normal.copyWith(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.toggleFavorite(productModel),
                              icon: controller.isLoading ? const SizedBox(
                                width: 30,
                                height: 30,
                                child:  CircularProgressIndicator()
                                ) : Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          product['productDetails'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: normal.copyWith(fontSize: 12, color: AppColors.darkGrey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product['price'] ?? ''}',
                              style: normal.copyWith(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  context.router.push(const LoginRoute());
                                  return;
                                }
                                final cartQuery = await FirebaseFirestore.instance
                                    .collection('cart')
                                    .where('userId', isEqualTo: user.uid)
                                    .where('productId', isEqualTo: product['id'])
                                    .limit(1)
                                    .get();
      
                                if (cartQuery.docs.isNotEmpty) {
                                  final cartDoc = cartQuery.docs.first;
                                  final currentQty = (cartDoc['qty'] ?? 1) as int;
                                  await cartDoc.reference.update({'qty': currentQty + 1});
                                } else {
                                  await FirebaseFirestore.instance.collection('cart').add({
                                    'userId': user.uid,
                                    'productId': product['id'],
                                    'qty': 1,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to cart')),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart, size: 14),
                              label: Text(loc.addToCart, style: const TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                textStyle: const TextStyle(fontSize: 10),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      },
      
      
    );
  }
}
