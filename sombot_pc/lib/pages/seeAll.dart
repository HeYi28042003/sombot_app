import 'package:flutter/cupertino.dart';
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

class SeeAll extends StatefulWidget {
  const SeeAll({super.key});

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categoryProducts = [];
  bool _isCategoryProductsLoading = false;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false)
          .loadFavoritesFromFirestore();
    });
  }

  Future<void> fetchOrders() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('Product Master').get();
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
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
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

    final allList = _selectedCategoryId == null ? _orders : _categoryProducts;
    final displayList = _searchQuery.isEmpty
        ? allList
        : allList.where((product) {
            final name =
                (product['productName'] ?? '').toString().toLowerCase();
            final details =
                (product['productDetails'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                details.contains(_searchQuery);
          }).toList();

    final isLoading =
        _selectedCategoryId == null ? _isLoading : _isCategoryProductsLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: _buildSearchField(loc),
        toolbarHeight: 65,
        iconTheme: IconThemeData(
          color: AppColors.text,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // _buildSearchField(loc),
            const SizedBox(height: 10),
            if (isLoading)
              // const Center(child: CircularProgressIndicator())
              _loadingGrid(screenWidth)
            else
              _buildGrid(displayList, loc, productController, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        height: 50,
        child: TextField(
          cursorColor: AppColors.primary,
          style: TextStyle(
            color: AppColors.text,
          ),
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: loc.search,
            hintStyle: TextStyle(
              color: AppColors.grey,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.text,
            ),
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(8),
            // ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.text,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingGrid(double screenWidth) {
    double aspectRatio = screenWidth > 400 ? 0.7 : 0.58;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.second2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> products, AppLocalizations loc,
      ProductController controller, double screenWidth) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products found.',
          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      );
    }

    double aspectRatio = screenWidth > 400 ? 0.7 : 0.58;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final productModel = ProductsModel.fromMap(product['id'], product);
        final isFavorite = controller.isInFavorites(productModel);

        return InkWell(
          onTap: () =>
              context.router.push(DetailRoute(productModel: productModel)),
          child: Container(
            decoration: BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.2),
              //     blurRadius: 10,
              //     offset: const Offset(0, 5),
              //   ),
              // ],
              color: AppColors.second2,
              // border: Border.all(
              //   color: AppColors.grey.withOpacity(0.2),
              //   width: 1,
              // ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.text,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                              style: ThemeStyles.normal(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                context.router.pushNamed('/login');
                                return;
                              }
                              controller.toggleFavorite(productModel);
                            },
                            icon: controller.isLoading
                                ? const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(),
                                  )
                                : Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? AppColors.error
                                        : AppColors.text,
                                    size: 30,
                                  ),
                          ),
                        ],
                      ),
                      Text(
                        product['productDetails'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: ThemeStyles.normal(context)
                            .copyWith(fontSize: 12, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product['price'] ?? ''}',
                            style: ThemeStyles.normal(context).copyWith(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                context.router.pushNamed('/login');
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
                                await cartDoc.reference
                                    .update({'qty': currentQty + 1});
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('cart')
                                    .add({
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
                            label: Text(loc.addToCart,
                                style: const TextStyle(fontSize: 10)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              textStyle: const TextStyle(fontSize: 10),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.text,
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
  }
}
