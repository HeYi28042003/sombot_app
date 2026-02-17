import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CartController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;

  double get total => cartItems.fold(
      0.0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['qty'] ?? 1)));

  /// 🔹 Load cart stream
  Stream<QuerySnapshot> cartStream() {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: user!.uid)
        .snapshots();
  }

  /// 🔹 Load cart with stream listener
  void loadCart() {
    cartStream().listen((snapshot) {
      fetchCartProducts(snapshot.docs);
    });
  }

  /// 🔹 Fetch products
  Future<void> fetchCartProducts(List<QueryDocumentSnapshot> docs) async {
    isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> items = [];

    for (var doc in docs) {
      final cartData = doc.data() as Map<String, dynamic>;
      final productId = cartData['productId'];

      final productDoc =
          await _firestore.collection('Product Master').doc(productId).get();

      final productData = productDoc.data() ?? {};

      items.add({
        ...cartData,
        'productName': productData['productName'] ?? '',
        'price': productData['price'] ?? 0.0,
        'cartDocId': doc.id,
        'image': productData['image'],
        'productDetails': productData['productDetails'] ?? '',
        'qty': cartData['qty'] ?? 1,
      });
    }

    cartItems = items;
    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Increase qty
  Future<void> increaseQty(String docId, int qty) async {
    await _firestore.collection('cart').doc(docId).update({'qty': qty + 1});
  }

  /// 🔹 Decrease qty
  Future<void> decreaseQty(String docId, int qty) async {
    if (qty > 1) {
      await _firestore.collection('cart').doc(docId).update({'qty': qty - 1});
    } else {
      await _firestore.collection('cart').doc(docId).delete();
    }
  }

  /// 🔹 Delete item
  Future<void> deleteItem(String docId) async {
    await _firestore.collection('cart').doc(docId).delete();
  }

  /// 🔹 Clear all cart items
  Future<void> clearCart() async {
    try {
      final userId = user?.uid;
      if (userId == null) return;

      final cartDocs = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }

      cartItems = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  /// 🔹 Add to cart
  Future<void> addToCart(String productId) async {
    try {
      final userId = user?.uid;
      if (userId == null) return;

      // Check if product already exists in cart
      final existingCart = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingCart.docs.isNotEmpty) {
        // If product exists, increase quantity
        final docId = existingCart.docs.first.id;
        final currentQty = existingCart.docs.first['qty'] ?? 1;
        await increaseQty(docId, currentQty);
      } else {
        // If product doesn't exist, add new item
        await _firestore.collection('cart').add({
          'userId': userId,
          'productId': productId,
          'qty': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  /// 🔹 Generate invoice
  Future<void> generateInvoice() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Date: ${DateTime.now()}'),
            pw.SizedBox(height: 10),
            ...cartItems.map((item) {
              final qty = item['qty'];
              final price = item['price'];
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item['productName']),
                  pw.Text('x$qty'),
                  pw.Text('\$${(qty * price).toStringAsFixed(2)}'),
                ],
              );
            }),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${total.toStringAsFixed(2)}'),
              ],
            )
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
