import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/pages/detail_page.dart';
import 'package:sombot_pc/utils/colors.dart';
import 'package:sombot_pc/utils/text_style.dart';

class SearchProductPage extends StatefulWidget {
  const SearchProductPage({super.key});

  @override
  State<SearchProductPage> createState() => _SearchProductPageState();
}

class _SearchProductPageState extends State<SearchProductPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ProductsModel> _allProduct = [];
  List<ProductsModel> _filteredProduct = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // fetchProducts();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Product Master')
          .limit(50)
          .get();
      List<ProductsModel> products = snapshot.docs.map((doc) {
        var id = doc.id;
        return ProductsModel.fromMap(id, doc.data());
      }).toList();
      setState(() {
        _allProduct = products;
        _filteredProduct = products;
      });
    } catch (e) {
      print('Error fetching all products: $e');
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredProduct = [];
        _searchController.clear();
        return;
      }
      {
        fetchProducts();
      }

      _filteredProduct = _allProduct.where((product) {
        final name = (product.productName ?? '').toLowerCase();
        final details = (product.productDetails ?? '').toLowerCase();
        return name.contains(value.toLowerCase()) ||
            details.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              cursorColor: AppColors.primary,
              style: TextStyle(
                color: AppColors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search Products',
                hintStyle: TextStyle(
                  color: AppColors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.white,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppColors.white,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.white,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _filteredProduct.isEmpty
                ? const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: AppColors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProduct.length,
                    itemBuilder: (context, index) {
                      var product = _filteredProduct[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.grey,
                            ),
                            child: Image.memory(
                              Base64Codec().decode(product.image ?? ''),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(product.productName ?? 'No Name',
                              style:
                                  medium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(product.productDetails ?? '',
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Text(
                            '\$${product.price ?? 'N/A'}',
                            style: medium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentDark,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  productModel: product,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
