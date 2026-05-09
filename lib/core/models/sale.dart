import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String productId;
  final String productName;
  final String brandName;
  final String? customerName;
  final double quantitySold; // Supports units and meters
  final double costPrice; // At time of sale
  final double sellingPrice; // At time of sale
  final double totalPrice;
  final double profit;
  final DateTime timestamp;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.brandName,
    this.customerName,
    required this.quantitySold,
    required this.costPrice,
    required this.sellingPrice,
    required this.totalPrice,
    required this.profit,
    required this.timestamp,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      brandName: data['brandName'] ?? '',
      customerName: data['customerName'],
      quantitySold: (data['quantitySold'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      profit: (data['profit'] ?? 0).toDouble(),
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'brandName': brandName,
      'customerName': customerName,
      'quantitySold': quantitySold,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'totalPrice': totalPrice,
      'profit': profit,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
