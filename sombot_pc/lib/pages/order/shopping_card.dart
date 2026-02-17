// ignore_for_file: use_build_context_synchronously, avoid_types_as_parameter_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/card_contrller.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/home/detail_page.dart';
import 'package:sombot_pc/pages/order/order.dart';
import 'package:sombot_pc/utils/text_style.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartController>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.myOrder, style: ThemeStyles.medium(context)),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final cartController =
                  Provider.of<CartController>(context, listen: false);
              if (cartController.cartItems.isNotEmpty) {
                await cartController.generateInvoice();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Invoice generated successfully!')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<CartController>(
        builder: (context, cartController, _) {
          if (cartController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartController.cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
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
                              (item['imagePreview'] as List?)?.cast<String>() ??
                                  [],
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
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
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
                                        width: 60,
                                        height: 60,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['productName'] ?? '',
                                        style: TextStyle(
                                          color: theme.unselectedWidgetColor
                                              .withOpacity(0.7),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['productDetails'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.unselectedWidgetColor
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('\$${item['price'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: () {
                                          cartController.decreaseQty(
                                              item['cartDocId'], qty);
                                        },
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () {
                                          cartController.increaseQty(
                                              item['cartDocId'], qty);
                                        },
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      cartController
                                          .deleteItem(item['cartDocId']);
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
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.total,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${cartController.total.toStringAsFixed(2)}',
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
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderSummaryPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStatePropertyAll(theme.primaryColor),
                          backgroundColor: WidgetStatePropertyAll(
                              theme.scaffoldBackgroundColor),
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: theme.primaryColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(loc.order,
                              style: ThemeStyles.medium(context)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
