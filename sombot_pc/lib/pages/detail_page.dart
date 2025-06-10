import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/data/models/product_model.dart';

@RoutePage()
class DetailScreen extends StatefulWidget {
  DetailScreen({super.key, this.productModel});
  ProductsModel? productModel;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  int cartQty = 0;
  String? cartDocId;
  double cartPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _fetchCartQty();
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
        cartQty = 0;
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('Detail Screen'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.router.pop();
                },
              ),
            ),
            CarouselDemo(imageUrls: widget.productModel?.imagePreview ?? []),
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
                        fontWeight: FontWeight.bold),
                  ),
                  // --- Real-time favorite icon ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseAuth.instance.currentUser == null ||
                            widget.productModel == null
                        ? const Stream.empty()
                        : FirebaseFirestore.instance
                            .collection('favorites')
                            .where('userId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('productId',
                                isEqualTo: widget.productModel!.id)
                            .snapshots(),
                    builder: (context, snapshot) {
                      final isFavorite =
                          snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                      return IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                      );
                    },
                  ),
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
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity Available',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.quantity == 0
                            ? '0'
                            : '${widget.productModel?.quantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Screen Size: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '15.6 Inches',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      const Text(
                        'Brand: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.category ?? 'No brand',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      const Text(
                        'Hard Disk Size: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.storageGB == 0
                            ? 'No storage'
                            : '${widget.productModel?.storageGB} GB',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      const Text(
                        'Color: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.color ?? 'No color',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      const Text(
                        'RAM Size: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.ramGB == 0
                            ? 'No RAM'
                            : '${widget.productModel?.ramGB} GB',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      const Text(
                        'Status: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.productModel?.quantity == 0
                            ? 'Out of stock'
                            : 'In stock',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      elevation: 0,
                      child: ExpansionTile(
                        title: const Text('Item Details'),
                        children: [
                          Text(widget.productModel?.productDetails ??
                              'No description')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: widget.productModel?.quantity == 0
                              ? null
                              : _addToCart,
                          icon: const Icon(Icons.shopping_cart),
                          label: Text(cartQty > 0
                              ? 'Add More (${cartQty} in cart)'
                              : 'Add to Cart'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _decreaseQty,
                      ),
                      Text('$cartQty', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _increaseQty,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
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
