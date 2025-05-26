import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          final cartDocs = snapshot.data!.docs;

          // Use a FutureBuilder to fetch all product details and calculate total
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchCartProducts(cartDocs),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final cartItems = productSnapshot.data!;
              double total = cartItems.fold(
                0.0,
                (sum, item) => sum + (item['price'] ?? 0.0),
              );
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final qty = item['qty'] ?? 1;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(item['productName'] ?? 'No Name'),
                            subtitle: Text('ID: ${item['productId']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () async {
                                    if (qty > 1) {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(item['cartDocId'])
                                          .update({'qty': qty - 1});
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(item['cartDocId'])
                                          .delete();
                                    }
                                  },
                                ),
                                Text('$qty',
                                    style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(item['cartDocId'])
                                        .update({'qty': qty + 1});
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '฿${((item['price'] ?? 0.0) * qty).toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(item['cartDocId'])
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '฿${cartItems.fold(0.0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['qty'] ?? 1))).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showPaymentOptions(context);
                            },
                            child: const Text('Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper to fetch product details for all cart items
  Future<List<Map<String, dynamic>>> _fetchCartProducts(
      List<QueryDocumentSnapshot> cartDocs) async {
    List<Map<String, dynamic>> cartItems = [];
    for (var doc in cartDocs) {
      final cartData = doc.data() as Map<String, dynamic>;
      final productId = cartData['productId'];
      final productDoc = await FirebaseFirestore.instance
          .collection('Product Master')
          .doc(productId)
          .get();
      final productData = productDoc.data() ?? {};
      cartItems.add({
        ...cartData,
        'productName': productData['productName'] ?? 'No Name',
        'price': productData['price'] ?? 0.0,
        'cartDocId': doc.id,
      });
    }
    return cartItems;
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Image.asset('assets/images/aba.png', width: 30),
                title: const Text('Pay with ABA'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle ABA payment
                },
              ),
              ListTile(
                leading: Image.asset('assets/images/ac.png', width: 30),
                title: const Text('Pay with ACLEDA'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle ACLEDA payment
                },
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Cash on delivery'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle cash on delivery
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
