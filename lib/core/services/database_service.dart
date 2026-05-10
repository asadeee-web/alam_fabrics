import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/product.dart';
import '../models/sale.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products Stream
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // Sales Stream
  Stream<List<Sale>> getSales() {
    return _db
        .collection('sales')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList(),
        );
  }

  // Add Product
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  // Update Product
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // Delete Product
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // Delete Sale and restore stock
  Future<String?> deleteSale(Sale sale) async {
    try {
      await _db.runTransaction((transaction) async {
        DocumentReference productRef = _db.collection('products').doc(sale.productId);
        DocumentReference saleRef = _db.collection('sales').doc(sale.id);

        // Get current product data
        DocumentSnapshot productDoc = await transaction.get(productRef);
        if (productDoc.exists) {
          double currentQty = (productDoc.get('quantity') ?? 0).toDouble();
          // Add back the quantity sold
          transaction.update(productRef, {'quantity': currentQty + sale.quantitySold});
        }

        // Delete the sale record
        transaction.delete(saleRef);
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Record Sale (with Transaction)
  Future<String?> recordSale(
    Product product,
    double quantitySold, {
    String? customerName,
    DateTime? customDate,
  }) async {
    if (quantitySold > product.quantity) {
      return "Not enough stock available!";
    }

    try {
      await _db.runTransaction((transaction) async {
        DocumentReference productRef = _db
            .collection('products')
            .doc(product.id);

        // Get fresh product data
        DocumentSnapshot productDoc = await transaction.get(productRef);
        double currentQty = (productDoc.get('quantity') ?? 0).toDouble();

        if (currentQty < quantitySold) {
          throw Exception("Insufficient stock during transaction");
        }

        // Subtract from stock
        transaction.update(productRef, {'quantity': currentQty - quantitySold});

        // Add sale record
        double totalPrice = product.sellingPrice * quantitySold;
        double profit =
            (product.sellingPrice - product.costPrice) * quantitySold;

        DocumentReference saleRef = _db.collection('sales').doc();
        Map<String, dynamic> saleData = {
          'productId': product.id,
          'productName': product.name,
          'brandName': product.brandName,
          'customerName': customerName,
          'quantitySold': quantitySold,
          'costPrice': product.costPrice,
          'sellingPrice': product.sellingPrice,
          'totalPrice': totalPrice,
          'profit': profit,
          'timestamp': customDate != null ? Timestamp.fromDate(customDate) : FieldValue.serverTimestamp(),
        };
        transaction.set(saleRef, saleData);
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Dashboard Stats
  Stream<Map<String, dynamic>> getDashboardStats() {
    return Rx.combineLatest2(
      _db.collection('products').snapshots(),
      _db.collection('sales').snapshots(),
      (QuerySnapshot productsSnap, QuerySnapshot salesSnap) {
        double totalInventoryValue = 0;
        int lowStockCount = 0;
        for (var doc in productsSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          double qty = (data['quantity'] ?? 0).toDouble();
          double cost = (data['costPrice'] ?? 0).toDouble();
          int threshold = data['lowStockThreshold'] ?? 5;

          totalInventoryValue += (qty * cost);
          if (qty <= threshold) lowStockCount++;
        }

        double totalSales = 0;
        double totalProfit = 0;
        double todaySales = 0;
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        for (var doc in salesSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          double amount = (data['totalPrice'] ?? 0).toDouble();
          double profit = (data['profit'] ?? 0).toDouble();
          Timestamp? ts = data['timestamp'] as Timestamp?;

          totalSales += amount;
          totalProfit += profit;

          if (ts != null) {
            DateTime saleDate = ts.toDate();
            if (saleDate.isAfter(today)) {
              todaySales += amount;
            }
          }
        }

        return {
          'totalProducts': productsSnap.docs.length,
          'lowStockCount': lowStockCount,
          'totalInventoryValue': totalInventoryValue,
          'totalSales': totalSales,
          'totalProfit': totalProfit,
          'todaySales': todaySales,
        };
      },
    );
  }
}

// Simple Rx replacement if rxdart is not used, or I can use StreamZip or just nested streams.
// Let's use a simpler approach without adding dependencies if possible, but CombineLatest is common.
// Since I don't have rxdart, I'll use a manual stream controller or nested streams.
class Rx {
  static Stream<T> combineLatest2<A, B, T>(
    Stream<A> streamA,
    Stream<B> streamB,
    T Function(A a, B b) combiner,
  ) {
    late StreamController<T> controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;
    A? lastA;
    B? lastB;
    bool hasA = false;
    bool hasB = false;

    controller = StreamController<T>(
      onListen: () {
        subA = streamA.listen(
          (a) {
            lastA = a;
            hasA = true;
            if (hasB) controller.add(combiner(lastA as A, lastB as B));
          },
          onError: controller.addError,
          onDone: controller.close,
        );
        subB = streamB.listen(
          (b) {
            lastB = b;
            hasB = true;
            if (hasA) controller.add(combiner(lastA as A, lastB as B));
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () {
        subA?.cancel();
        subB?.cancel();
      },
    );
    return controller.stream;
  }
}

// Removed import from bottom as I moved it to top
