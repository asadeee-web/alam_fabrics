import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/services/database_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  DashboardViewModel(this._dbService);

  Stream<Map<String, dynamic>> get statsStream => _dbService.getDashboardStats();

  Stream<List<Product>> get lowStockProducts {
    return _dbService.getProducts().map((products) {
      return products.where((p) => p.quantity <= 5).toList();
    });
  }
}
