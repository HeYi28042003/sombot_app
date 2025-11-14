import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'dart:convert';
import 'package:sombot_pc/pages/home/detail_page.dart';
import 'package:sombot_pc/utils/colors.dart';
import 'package:sombot_pc/utils/text_style.dart';

@RoutePage()
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> removeFavorite(String docId) async {
    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(docId)
        .delete();
    setState(() {});
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final cartQuery = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: product['productId'])
        .limit(1)
        .get();

    if (cartQuery.docs.isNotEmpty) {
      final cartDoc = cartQuery.docs.first;
      final currentQty = (cartDoc['qty'] ?? 1) as int;
      await cartDoc.reference.update({'qty': currentQty + 1});
    } else {
      await FirebaseFirestore.instance.collection('cart').add({
        'userId': user.uid,
        'productId': product['productId'],
        'qty': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(
        child: Text(
          'Please login to view favorites.',
          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      );
    }
    return Scaffold(
      // appBar: AppBar(title: const Text('Favorites')),
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No favorites found.',
                style: TextStyle(
                  color: AppColors.text,
                ),
              ),
            );
          }
          final favorites = snapshot.data!.docs;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              final data = fav.data() as Map<String, dynamic>;
              final productId = data['productId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Product Master')
                    .doc(productId)
                    .get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    // return ListTile(
                    //   title: Text(
                    //     'Loading...',
                    //     style: TextStyle(
                    //       color: AppColors.text,
                    //     ),
                    //   ),
                    // );
                    return Container(
                      width: double.infinity,
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.second,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    );
                  }
                  if (!productSnapshot.hasData ||
                      !productSnapshot.data!.exists) {
                    return ListTile(
                      title: Text(
                        'Product not found',
                        style: TextStyle(
                          color: AppColors.text,
                        ),
                      ),
                    );
                  }
                  final product =
                      productSnapshot.data!.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            productModel:
                                ProductsModel.fromMap(productId, product),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: AppColors.second2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: product['image'] != null
                            ? Image.memory(
                                base64Decode(product['image']),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(width: 60, height: 60),
                        title: Text(
                          product['productName'] ?? '',
                          style: ThemeStyles.medium(context),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['productDetails'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ThemeStyles.normal(context),
                            ),
                            Text(
                              '฿${product['price'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              onPressed: () => addToCart(data),
                              tooltip: 'Add to cart',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => removeFavorite(fav.id),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
