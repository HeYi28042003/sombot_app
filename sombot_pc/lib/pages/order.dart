import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sombot_pc/api/map_api.dart';
import 'package:sombot_pc/data/models/map_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/map.dart';
import 'package:sombot_pc/utils/colors.dart';
import 'package:sombot_pc/utils/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const OrderSummaryPage({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String? _selectedPayment;
  bool _isLoadingAddress = false;
  PlaceModel? _place;
  LatLng? _currentLatLng;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
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
        _currentLatLng = LatLng(_place!.lat, _place!.lon);
        _marker = Marker(
          markerId: const MarkerId('selected_location'),
          position: _currentLatLng!,
        );
      });
    }
  }

  Future<void> _openABAApp() async {
    final uri = Uri.parse("https://link.payway.com.kh/ABAPAYXj375803b");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ABA app not installed.")),
      );
    }
  }

  Future<void> _selectAddress(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChooseLocationScreen()),
    );

    if (location != null) {
      setState(() => _isLoadingAddress = true);

      final address = await MapApi().reverseGeocode(
        lat: location.latitude,
        lon: location.longitude,
        onLoading: (loading) => setState(() => _isLoadingAddress = loading),
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

        final userRef = FirebaseFirestore.instance.collection('users');
        final existingDocs =
            await userRef.where('uid', isEqualTo: user.uid).limit(1).get();

        if (existingDocs.docs.isNotEmpty) {
          await existingDocs.docs.first.reference.update({
            'address': address.displayName,
            'latitude': location.latitude,
            'longitude': location.longitude,
          });
        } else {
          await userRef.add({
            'userId': user.uid,
            'address': address.displayName,
            'latitude': location.latitude,
            'longitude': location.longitude,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get address.')),
        );
      }

      setState(() => _isLoadingAddress = false);
    }
  }

  void _confirmOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final addressText = _place?.displayName ?? 'Unknown';
      final items = widget.cartItems.map((item) {
        return {
          'productId': item['productId'],
          'productName': item['productName'],
          'qty': item['qty'],
          'price': item['price'],
          'subtotal': (item['qty'] ?? 1) * (item['price'] ?? 0.0),
        };
      }).toList();

      final orderData = {
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'total': widget.total,
        'paymentMethod': _selectedPayment,
        'address': addressText,
        'items': items,
        'status': 'pending',
      };

      try {
        await FirebaseFirestore.instance
            .collection('order_history')
            .add(orderData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(title: const Text('Order Summary')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Order Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        final qty = item['qty'] ?? 1;
                        final price = item['price'] ?? 0.0;
                        return Card(
                          child: ListTile(
                            title: Text(item['productName']),
                            subtitle: Text('Qty: $qty'),
                            trailing:
                                Text('฿${(qty * price).toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    cardAddress(_place),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoadingAddress
                          ? null
                          : () => _selectAddress(context),
                      child: _isLoadingAddress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.chanegAddress),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('฿${widget.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Payment Method',
                        style: TextStyle(fontSize: 16)),
                    RadioListTile<String>(
                      value: 'ABA',
                      groupValue: _selectedPayment,
                      title: const Text('Pay with ABA'),
                      onChanged: (value) async {
                        setState(() => _selectedPayment = value);
                        await _openABAApp();
                      },
                    ),
                    // RadioListTile<String>(
                    //   value: 'ACLEDA',
                    //   groupValue: _selectedPayment,
                    //   title: const Text('Pay with ACLEDA'),
                    //   onChanged: (value) =>
                    //       setState(() => _selectedPayment = value),
                    // ),
                    RadioListTile<String>(
                      value: 'COD',
                      groupValue: _selectedPayment,
                      title: const Text('Cash on Delivery'),
                      onChanged: (value) =>
                          setState(() => _selectedPayment = value),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _selectedPayment == null ? null : _confirmOrder,
                      child: const Text('Confirm Order'),
                    )
                  ],
                ),
              ),
              if (_isLoadingAddress)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ));
  }

  Widget cardAddress(PlaceModel? place) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
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
            Text(
              place?.displayName ?? 'Your Address',
              style: ThemeStyles.normal(context).copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
