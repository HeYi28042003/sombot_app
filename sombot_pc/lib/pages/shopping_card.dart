import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sombot_pc/api/map_api.dart';
import 'package:sombot_pc/data/models/map_model.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/pages/detail_page.dart';
import 'package:sombot_pc/pages/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sombot_pc/utils/text_style.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  bool _isLoadingAddress = false;
  PlaceModel? _place;
  LatLng? _currentLatLng;
  Marker? _marker;

  Future<void> _loadUserAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('user_addresses')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _place = PlaceModel(
          displayName: data['address'] ?? '',
          lat: data['latitude'] ?? 0.0,
          lon: data['longitude'] ?? 0.0,
          address: Address(city: 'Detected City'),
        );
        _currentLatLng = LatLng(_place!.lat , _place!.lon);
        _marker = Marker(
          markerId: const MarkerId('selected_location'),
          position: _currentLatLng!,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final api = MapApi();

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
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
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCartProducts(cartDocs),
                builder: (context, productSnapshot) {
                  if (!productSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cartItems = productSnapshot.data!;
                  double total = cartItems.fold(0.0, (sum, item) =>
                      sum + ((item['price'] ?? 0.0) * (item['qty'] ?? 1)));

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final qty = item['qty'] ?? 1;

                            return GestureDetector(
                              onTap: () {
                                final product = ProductsModel(
                                  id: item['productId'],
                                  productName: item['productName'] ?? '',
                                  productDetails: item['productDetails'] ?? '',
                                  price: (item['price'] ?? 0.0).toDouble(),
                                  quantity: item['quantity'],
                                  imagePreview:
                                      (item['imagePreview'] as List?)?.cast<String>() ?? [],
                                  ramGB: item['ramGB'] ?? 0,
                                  storageGB: item['storageGB'],
                                  color: item['color'],
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(productModel: product),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item['image'] != null
                                            ? Image.memory(
                                                base64Decode(item['image']),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox(
                                                width: 60, height: 60),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item['productName'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(item['productDetails'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54)),
                                            const SizedBox(height: 6),
                                            Text('฿${item['price'] ?? ''}',
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                                onPressed: () async {
                                                  if (qty > 1) {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('cart')
                                                        .doc(item['cartDocId'])
                                                        .update({'qty': qty - 1});
                                                  } else {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('cart')
                                                        .doc(item['cartDocId'])
                                                        .delete();
                                                  }
                                                },
                                              ),
                                              Text('$qty',
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                              IconButton(
                                                icon: const Icon(Icons
                                                    .add_circle_outline),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('cart')
                                                      .doc(item['cartDocId'])
                                                      .update({'qty': qty + 1});
                                                },
                                              ),
                                            ],
                                          ),
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
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // if (_marker != null && _currentLatLng != null)
                      //   SizedBox(
                      //     height: 200,
                      //     child: GoogleMap(
                      //       initialCameraPosition: CameraPosition(
                      //         target: _currentLatLng!,
                      //         zoom: 16,
                      //       ),
                      //       markers: {_marker!},
                      //       onMapCreated: (controller) {},
                      //     ),
                      //   ),
                      cardAddress(_place),
                      ElevatedButton(
                        onPressed: _isLoadingAddress
                            ? null
                            : () async {
                                final location = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChooseLocationScreen(),
                                  ),
                                );
                                if (location != null) {
                                  setState(() {
                                    _isLoadingAddress = true;
                                  });

                                  final address = await api.reverseGeocode(
                                    lat: location.latitude,
                                    lon: location.longitude,
                                    onLoading: (loading) {
                                      setState(() {
                                        _isLoadingAddress = loading;
                                      });
                                    },
                                  );

                                  if (address != null) {
                                    setState(() {
                                      _place = address;
                                      _currentLatLng = LatLng(location.latitude, location.longitude);
                                      _marker = Marker(
                                        markerId: const MarkerId('selected_location'),
                                        position: _currentLatLng!,
                                      );
                                    });

                                    final existingDocs = await FirebaseFirestore.instance
                                        .collection('user_addresses')
                                        .where('userId', isEqualTo: user.uid)
                                        .limit(1)
                                        .get();

                                    if (existingDocs.docs.isNotEmpty) {
                                      await existingDocs.docs.first.reference.update({
                                        'address': address.displayName,
                                        'latitude': location.latitude,
                                        'longitude': location.longitude,
                                      });
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('user_addresses')
                                          .add({
                                        'userId': user.uid,
                                        'address': address.displayName,
                                        'latitude': location.latitude,
                                        'longitude': location.longitude,
                                      });
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Address saved successfully!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Failed to get address.')),
                                    );
                                  }

                                  setState(() {
                                    _isLoadingAddress = false;
                                  });
                                }
                              },
                        child: _isLoadingAddress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Change Address"),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
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
          if (_isLoadingAddress)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

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
        'image': productData['image'],
        'imagePreview': productData['imagePreview'] ?? [],
        'productDetails': productData['productDetails'] ?? '',
        'ramGB': productData['ramGB'] ?? 0,
        'storageGB': productData['storageGB'] ?? 0,
        'color': productData['color'] ?? '',
        'quantity': productData['quantity'] ?? 0,
        'qty': cartData['qty'] ?? 1,
      });
    }
    return cartItems;
  }

  Widget cardAddress(PlaceModel? place) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place?.displayName ?? 'Your Address',
                style:
                    normal),
            const SizedBox(height: 8),
            // Text(place?.address?.city ?? 'City not set',
            //     style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Image.asset('assets/images/aba.png', width: 30),
                title: const Text('Pay with ABA'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Image.asset('assets/images/ac.png', width: 30),
                title: const Text('Pay with ACLEDA'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Cash on delivery'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}