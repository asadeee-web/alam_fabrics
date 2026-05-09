import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/sale.dart';
import '../../../core/services/database_service.dart';

class SalesViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  SalesViewModel(this._dbService);

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController customerController = TextEditingController();

  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Stream<List<Product>> get productsStream => _dbService.getProducts();
  Stream<List<Sale>> get salesStream => _dbService.getSales();

  Future<String?> recordSale() async {
    if (_selectedProduct == null) return 'Please select a product';
    final qty = double.tryParse(quantityController.text);
    if (qty == null || qty <= 0) return 'Please enter a valid quantity';

    _isProcessing = true;
    notifyListeners();

    final error = await _dbService.recordSale(
      _selectedProduct!,
      qty,
      customerName: customerController.text.trim().isEmpty
          ? null
          : customerController.text.trim(),
    );

    _isProcessing = false;
    if (error == null) {
      quantityController.clear();
      customerController.clear();
      _selectedProduct = null;
    }
    notifyListeners();
    return error;
  }

  @override
  void dispose() {
    quantityController.dispose();
    customerController.dispose();
    super.dispose();
  }
}
