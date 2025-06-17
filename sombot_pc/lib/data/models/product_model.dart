import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel {
  String? id;
  String? productCode;
  String? productName;
  String? category;
  String? productDetails;
  int? quantity;
  
  double? price;
  String? expireDate;
  String? supplierId;
  String? image;
  List<String>? imagePreview;
  final String? color;
  final int? storageGB;
  final String? cpuModel;
  final String? cpuName;
  final String? os;
  final int? ramGB;
  final String? gpu;
  final String? style;
  final String? createdAt;

  ProductsModel({
    this.id,
    this.productCode,
    this.productName,
    this.category,
    this.productDetails,
    this.quantity,
    this.price,
    this.expireDate,
    this.supplierId,
    this.image,
    this.imagePreview,
    this.color,
    this.storageGB,
    this.cpuModel,
    this.cpuName,
    this.os,
    this.ramGB,
    this.gpu,
    this.style,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productCode': productCode,
      'productName': productName,
      'category': category,
      'productDetails': productDetails,
      'quantity': quantity,
      'price': price,
      'expireDate': expireDate,
      'supplierId': supplierId,
      'image': image,
      'imagePreview': imagePreview,
      'color': color,
      'storageGB': storageGB,
      'cpuModel': cpuModel,
      'cpuName': cpuName,
      'os': os,
      'ramGB': ramGB,
      'gpu': gpu,
      'style': style,
      'createdAt': DateTime.now(),
    };
  }

  factory ProductsModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductsModel(
      id: id,
      productCode: map['productCode'] ?? '',
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      productDetails: map['productDetails'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      expireDate: map['expireDate'] ?? '',
      supplierId: map['supplierId'] ?? '',
      image: map['image'],
      imagePreview: List<String>.from(map['imagePreview'] ?? []),
      color: map['color'],
      storageGB: map['storageGB'],
      cpuModel: map['cpuModel'],
      cpuName: map['cpuName'],
      os: map['os'],
      ramGB: map['ramGB'],
      gpu: map['gpu'],
      style: map['style'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
    );
  }
}
