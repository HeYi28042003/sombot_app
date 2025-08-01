// ignore_for_file: unused_element, must_be_immutable

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sombot_pc/controller/product_controller.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class DetailScreen extends StatefulWidget {
  DetailScreen({super.key, this.productModel});
  ProductsModel? productModel;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PageController _pageController = PageController();
  bool isFavorite = false;
  int cartQty = 1;
  String? cartDocId;
  double cartPrice = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _fetchCartQty();
    Provider.of<ProductController>(context, listen: false)
        .loadFavoritesFromFirestore();
  }

  Future<void> _checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.productModel == null) return;
    final favQuery = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: widget.productModel!.id)
        .get();
    setState(() {
      isFavorite = favQuery.docs.isNotEmpty;
    });
  }

  Future<void> _fetchCartQty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.productModel == null) return;
    final cartQuery = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: widget.productModel!.id)
        .limit(1)
        .get();
    if (cartQuery.docs.isNotEmpty) {
      final doc = cartQuery.docs.first;
      setState(() {
        cartQty = (doc['qty'] ?? 1) as int;
        cartDocId = doc.id;
        cartPrice = ((widget.productModel?.price ?? 0.0) * cartQty).toDouble();
      });
    } else {
      setState(() {
        cartQty = 1;
        cartDocId = null;
        cartPrice = 0.0;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.productModel == null) return;
    final favQuery = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: widget.productModel!.id)
        .get();

    if (favQuery.docs.isNotEmpty) {
      // Remove from favorites
      await favQuery.docs.first.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } else {
      // Add to favorites
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': user.uid,
        'productId': widget.productModel!.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    }
    // Always reload favorite status after change
    await _checkFavorite();
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.productModel == null) return;
    if (cartQty > 0 && cartDocId != null) {
      // Already in cart, increment qty
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartDocId)
          .update({'qty': cartQty + 1});
    } else {
      // Add new product to cart with qty 1
      final docRef = await FirebaseFirestore.instance.collection('cart').add({
        'userId': user.uid,
        'productId': widget.productModel!.id,
        'qty': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
      cartDocId = docRef.id;
    }
    await _fetchCartQty();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  Future<void> _increaseQty() async {
    if (cartDocId != null) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartDocId)
          .update({'qty': cartQty + 1});
      await _fetchCartQty();
    }
  }

  Future<void> _decreaseQty() async {
    if (cartDocId != null) {
      if (cartQty > 1) {
        await FirebaseFirestore.instance
            .collection('cart')
            .doc(cartDocId)
            .update({'qty': cartQty - 1});
      } else {
        await FirebaseFirestore.instance
            .collection('cart')
            .doc(cartDocId)
            .delete();
      }
      await _fetchCartQty();
    }
  }

  Future<void> _removeFromCart() async {
    if (cartDocId != null) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartDocId)
          .delete();
      await _fetchCartQty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.productModel?.price ?? 0.0;
    final controller = Provider.of<ProductController>(context);
    final isFav = controller.isInFavorites(widget.productModel!);
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: Text(
                'Detail Screen',
                style: TextStyle(
                  color: AppColors.text,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.router.pop();
                },
                color: AppColors.text,
              ),
              backgroundColor: AppColors.transparent,
              elevation: 0,
            ),
            Container(
              width: double.infinity,
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.productModel?.imagePreview?.length ?? 0,
                itemBuilder: (context, index) {
                  var imgs = widget.productModel?.imagePreview?[index];
                  return ClipRRect(
                    //borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(imgs.toString()),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _pageController,
              count: widget.productModel?.imagePreview?.length ?? 0,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                // activeDotColor: Colors.black,
                activeDotColor: AppColors.primary,
                // dotColor: Colors.grey.shade300,
                dotColor: AppColors.text,
              ),
            ),
            // CarouselDemo(imageUrls: widget.productModel?.imagePreview ?? []),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.yellow[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : AppColors.text,
                      size: 30,
                    ),
                    onPressed: () async {
                      await controller.toggleFavorite(widget.productModel!);
                    },
                  ),
                  // --- Real-time favorite icon ---
                  // StreamBuilder<QuerySnapshot>(
                  //   stream: FirebaseAuth.instance.currentUser == null ||
                  //           widget.productModel == null
                  //       ? const Stream.empty()
                  //       : FirebaseFirestore.instance
                  //           .collection('favorites')
                  //           .where('userId',
                  //               isEqualTo:
                  //                   FirebaseAuth.instance.currentUser!.uid)
                  //           .where('productId',
                  //               isEqualTo: widget.productModel!.id)
                  //           .snapshots(),
                  //   builder: (context, snapshot) {
                  //     final isFavorite =
                  //         snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                  //     return IconButton(
                  //       onPressed: _toggleFavorite,
                  //       icon: Icon(
                  //         isFavorite ? Icons.favorite : Icons.favorite_border,
                  //         color: isFavorite ? Colors.red : Colors.grey,
                  //         size: 30,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productModel?.productName ?? 'No name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.quantity == 0
                            ? '0'
                            : '${widget.productModel?.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Screen Size: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '15.6 Inches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Brand: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.category ?? 'No brand',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hard Disk Size: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.storageGB == 0
                            ? 'No storage'
                            : '${widget.productModel?.storageGB} GB',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Color: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.color ?? 'No color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RAM Size: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.ramGB == 0
                            ? 'No RAM'
                            : '${widget.productModel?.ramGB} GB',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        widget.productModel?.quantity == 0
                            ? 'Out of stock'
                            : 'In stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: Card(
                      color: AppColors.second2,
                      elevation: 0,
                      child: ExpansionTile(
                        iconColor: AppColors.text,
                        collapsedIconColor: AppColors.text,
                        backgroundColor: AppColors.background,
                        title: Text(
                          loc.productDetail,
                          style: TextStyle(
                            color: AppColors.text,
                          ),
                        ),
                        children: [
                          Text(
                            widget.productModel?.productDetails ??
                                'No description',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.productModel?.quantity == 0
                            ? null
                            : _addToCart,
                        icon: Icon(
                          Icons.shopping_cart,
                          color: AppColors.text,
                        ),
                        label: Text(
                          cartQty > 0
                              ? '${loc.addMore} (${cartQty} in cart)'
                              : 'Add to Cart',
                          style: TextStyle(
                            color: AppColors.text,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.primary),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.text,
                            ),
                            onPressed: _decreaseQty,
                          ),
                          Text('$cartQty',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.text,
                              )),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.text,
                            ),
                            onPressed: _increaseQty,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CarouselDemo extends StatelessWidget {
  CarouselDemo({super.key, required this.imageUrls});

  List<String> imageUrls = [];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIdx) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(imageUrls[index]),
                fit: BoxFit.cover,
              )),
        );
      },
      options: CarouselOptions(
        height: 280,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }
}
