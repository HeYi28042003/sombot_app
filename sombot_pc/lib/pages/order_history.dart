import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage()
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your order history.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order_history')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = docs[index].data() as Map<String, dynamic>;
              final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
              final total = order['total'] ?? 0.0;
              final payment = order['paymentMethod'] ?? 'Unknown';
              final items = List<Map<String, dynamic>>.from(order['items'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text('Total: \$${total.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd – kk:mm').format(createdAt ?? DateTime.now())}\nPayment: $payment',
                    style: const TextStyle(fontSize: 12),
                  ),
                  children: items.map((item) {
                    return ListTile(
                      title: Text(item['productName'] ?? ''),
                      subtitle: Text('Qty: ${item['qty']}'),
                      trailing: Text('\$${item['subtotal']?.toStringAsFixed(2) ?? '0.00'}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
