import 'package:cloud_firestore/cloud_firestore.dart';

enum StockType { branded, meter }

class Product {
  final String id;
  final String brandName;
  final String itemType;
  final StockType stockType;
  final String? serialNumber;
  final double costPrice;
  final double sellingPrice;
  final double quantity; // Used for both units and meters
  final int lowStockThreshold;

  Product({
    required this.id,
    required this.brandName,
    required this.itemType,
    required this.stockType,
    this.serialNumber,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    this.lowStockThreshold = 5,
  });

  String get name => "$brandName - $itemType";
  double get profitPerUnit => sellingPrice - costPrice;
  bool get isLowStock => quantity <= lowStockThreshold;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      brandName: data['brandName'] ?? '',
      itemType: data['itemType'] ?? '',
      stockType: data['stockType'] == 'meter' ? StockType.meter : StockType.branded,
      serialNumber: data['serialNumber'],
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      lowStockThreshold: data['lowStockThreshold'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'itemType': itemType,
      'stockType': stockType == StockType.meter ? 'meter' : 'branded',
      'serialNumber': serialNumber,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
