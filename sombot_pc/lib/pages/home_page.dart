// ignore_for_file: unused_local_variable, avoid_print, unused_element

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redacted/redacted.dart';
import 'package:sombot_pc/controller/product_controller.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/filtter/populor_filtter.dart';
import 'package:sombot_pc/pages/seeAll.dart';
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
  final List<Map<String, dynamic>> _orders = [];
  // bool _isLoading = true;
  List<CategoryModel> _categories = [];
  bool _isCategoryLoading = true;
  String? _selectedCategoryId;
  final List<Map<String, dynamic>> _categoryProducts = [];
  //bool _isCategoryProductsLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
    fetchNews();
    fetchAllByViewer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false)
          .loadFavoritesFromFirestore();
    });
  }

  List<Map<String, dynamic>> _allProduct = [];
  Future<void> fetchProducts() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .limit(20)
          .get();
      List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      setState(() {
        _allProduct = products;
      });
    } catch (e) {
      print('Error fetching all products: $e');
    }
  }

  List<String> imgs = [];

  Future<void> fetchNews() async {
    try {
      // Fix: collection name should not have `=`, assuming you meant "Hot-News"
      var response =
          await FirebaseFirestore.instance.collection("Hot_News").get();

      // Loop through each document and extract the image URL (assumes field is named "image" or similar)
      for (var doc in response.docs) {
        String? imageUrl = doc.data()['image']; // Adjust field name if needed
        if (imageUrl != null) {
          imgs.add(imageUrl);
        }
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      if (!mounted) return;
      List<CategoryModel> categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
          .toList();
      categories.insert(0, CategoryModel(id: 'all', name: 'All', imageUrl: ''));
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print('Error fetching categories: $e');
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  // Future<void> fetchCategoryProducts(String categoryId) async {
  //   setState(() {
  //     _isCategoryProductsLoading = true;
  //     _selectedCategoryId = categoryId;
  //   });
  //   try {
  //     var snapshot = await FirebaseFirestore.instance
  //         .collection('Product Master')
  //         .where('category', isEqualTo: categoryId)
  //         .get();
  //     List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
  //       final data = doc.data();
  //       if (data['createdAt'] is Timestamp) {
  //         data['createdAt'] =
  //             (data['createdAt'] as Timestamp).toDate().toIso8601String();
  //       }
  //       return {'id': doc.id, ...data};
  //     }).toList();
  //     setState(() {
  //       _categoryProducts = products;
  //       _isCategoryProductsLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching category products: $e');
  //     setState(() {
  //       _isCategoryProductsLoading = false;
  //     });
  //   }
  // }
  String id = '';
  int viewer = 0;
  Future<void> viewerCount() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Product Master')
          .doc(id)
          .update({
        'viewer': viewer,
      });
    } catch (e) {
      print('Error fetching viewer count: $e');
    }
  }

  void incrementViewer() {
    setState(() {
      viewer++;
    });
  }

  List<Map<String, dynamic>> allByViewer = [];
  Future<void> fetchAllByViewer() async {
    try {
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
    } catch (e) {
      print('Error fetching products by viewer count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final filteredAllProducts = _searchQuery.isEmpty
        ? _allProduct
        : _allProduct.where((product) {
            final name =
                (product['productName'] ?? '').toString().toLowerCase();
            final details =
                (product['productDetails'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                details.contains(_searchQuery);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  _buildSearchField(loc),
            const SizedBox(height: 10),
            // Text(loc.hotNew, style: ThemeStyles.normal(context).copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            CarouselDemoWithIndicator(imageUrls: imgs),
            // Text("Category", style: ThemeStyles.normal(context).copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_searchQuery.isEmpty) _buildCategoryList(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                loc.popular,
                style: ThemeStyles.normal(context).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildHorizontalProductList(allByViewer, productController, loc),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("All Products",
                      style: ThemeStyles.normal(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      )),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeeAll(),
                          ));
                    },
                    child: Text(
                      loc.seeAll,
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildHorizontalProductList(
              filteredAllProducts,
              productController,
              loc,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations loc) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: loc.search,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCategoryList() {
    return _isCategoryLoading
        // ? const Center(child: CircularProgressIndicator())
        ? SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: const EdgeInsets.only(right: 12),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.second,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("asdfghjasdfgh"),
                    ],
                  ),
                ).redacted(
                  context: context,
                  redact: true,
                  configuration: RedactedConfiguration(
                    redactedColor: AppColors.second,
                  ),
                );
              },
            ),
          )
        : SizedBox(
            height: 60,
            child: ListView.builder(
              padding: EdgeInsets.only(right: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.id == _selectedCategoryId ||
                    (category.id == 'all' && _selectedCategoryId == null);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PopulorFiltter(categoryId: category.id),
                        ),
                      );
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.second2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.second2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (category.imageUrl.isNotEmpty)
                          Image.memory(
                            base64Decode(category.imageUrl),
                            width: 30,
                            height: 30,
                          ),
                        if (category.imageUrl.isNotEmpty)
                          const SizedBox(width: 8),
                        Text(category.name,
                            style: ThemeStyles.normal(context).copyWith(
                                color: isSelected
                                    ? AppColors.text
                                    : AppColors.text)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildHorizontalProductList(List<Map<String, dynamic>> products,
      ProductController controller, AppLocalizations loc) {
    if (products.isEmpty) {
      return SizedBox(
        height: 280,
        child: ListView.builder(
          padding: EdgeInsets.only(right: 12),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: AppColors.second,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("sadfghjdfghn"),
                        const SizedBox(height: 10),
                        Text(
                          "sdfghdfghsadfghjkhgfdsdfghsdfhghjgfdsweruyyk",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("\$10000"),
                            Container(
                              height: 32,
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ).redacted(
              context: context,
              redact: true,
              configuration: RedactedConfiguration(
                redactedColor: AppColors.second,
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: EdgeInsets.only(right: 12),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final productModel = ProductsModel.fromMap(product['id'], product);
          id = product['id'];
          final isFavorite = controller.isInFavorites(productModel);
          return GestureDetector(
            onTap: () {
              fetchAllByViewer();
              incrementViewer();
              viewerCount();
              context.router.push(DetailRoute(productModel: productModel));
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: AppColors.second2,
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //       color: Colors.black.withOpacity(0.1), blurRadius: 5),
                // ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.memory(
                      base64Decode(product['image']),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product['productName'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ThemeStyles.normal(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : AppColors.text,
                              ),
                              onPressed: () {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  context.router.pushNamed('/login');
                                  return;
                                }
                                controller.toggleFavorite(productModel);
                              },
                            )
                          ],
                        ),
                        Text(
                          product['productDetails'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeStyles.normal(context).copyWith(
                            fontSize: 12,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product['price']}',
                              style: ThemeStyles.normal(context).copyWith(
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
                                final cartQuery = await FirebaseFirestore
                                    .instance
                                    .collection('cart')
                                    .where('userId', isEqualTo: user.uid)
                                    .where('productId',
                                        isEqualTo: product['id'])
                                    .limit(1)
                                    .get();

                                if (cartQuery.docs.isNotEmpty) {
                                  final cartDoc = cartQuery.docs.first;
                                  final currentQty =
                                      (cartDoc['qty'] ?? 1) as int;
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
                                  const SnackBar(
                                      content: Text('Added to cart')),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart, size: 14),
                              label: Text(loc.addToCart,
                                  style: const TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.text,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CarouselDemoWithIndicator extends StatefulWidget {
  final List<String> imageUrls;
  const CarouselDemoWithIndicator({super.key, required this.imageUrls});

  @override
  State<CarouselDemoWithIndicator> createState() =>
      _CarouselDemoWithIndicatorState();
}

class _CarouselDemoWithIndicatorState extends State<CarouselDemoWithIndicator> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      // return const SizedBox.shrink();
      return Center(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: AppColors.second,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                  ),
                ],
              ),
              const SizedBox(height: 7),
            ],
          ).redacted(
            context: context,
            redact: true,
            configuration: RedactedConfiguration(
              redactedColor: AppColors.second,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        CarouselSlider(
          items: widget.imageUrls
              .map(
                (url) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(url),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              )
              .toList(),
          carouselController: _controller,
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // color: (Theme.of(context).brightness == Brightness.dark
                  //         ? Colors.text
                  //         : Colors.black)
                  //     .withOpacity(_current == entry.key ? 0.9 : 0.4),
                  color: _current == entry.key
                      ? AppColors.primary
                      : AppColors.text,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
