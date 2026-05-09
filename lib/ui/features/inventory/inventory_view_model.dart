import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/services/database_service.dart';

class InventoryViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  InventoryViewModel(this._dbService);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Stream<List<Product>> get filteredProducts {
    return _dbService.getProducts().map((products) {
      if (_searchQuery.isEmpty) return products;
      return products.where((p) {
        final query = _searchQuery.toLowerCase();
        return p.brandName.toLowerCase().contains(query) ||
            (p.serialNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _dbService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _dbService.deleteProduct(id);
  }
}
