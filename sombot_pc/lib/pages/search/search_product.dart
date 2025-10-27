// ignore_for_file: unused_import, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/product_controller.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/pages/home/detail_page.dart';
import 'package:sombot_pc/utils/colors.dart';
import 'package:sombot_pc/utils/text_style.dart';

class SearchProductPage extends StatelessWidget {
  const SearchProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: TextField(
              controller: productController.searchController,
              cursorColor: AppColors.primary,
              style: TextStyle(
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: 'Search Products',
                hintStyle: TextStyle(
                  color: AppColors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.text,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppColors.text,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                suffixIcon: productController.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.text,
                        ),
                        onPressed: () {
                          productController.searchController.clear();
                          productController.onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: productController.onSearchChanged,
            ),
          ),
          Expanded(
            child: productController.searchController.text.isEmpty
                ? Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: AppColors.text,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                      itemCount: productController.filteredProduct.length,
                      itemBuilder: (context, index) {
                        var product = productController.filteredProduct[index];
                        return Card(
                          color: AppColors.second2,
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // color: AppColors.grey,
                              ),
                              child: Image.memory(
                                Base64Codec().decode(product['image'] ?? ''),
                                width: 50,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                            title: Text(
                              product['productName'] ?? 'No Name',
                              style: ThemeStyles.medium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            subtitle: Text(
                              product['productDetails'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '\$${product['price'] ?? 'N/A'}',
                              style: ThemeStyles.medium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            onTap: () {
                              final productModel =
                                  ProductsModel.fromMap(product['id'], product);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    productModel: productModel,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
