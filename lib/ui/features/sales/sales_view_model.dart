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

  DateTime? _filterDate;
  DateTime? get filterDate => _filterDate;

  DateTime _saleDate = DateTime.now();
  DateTime get saleDate => _saleDate;

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void setSaleDate(DateTime date) {
    _saleDate = date;
    notifyListeners();
  }

  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  Stream<List<Product>> get productsStream => _dbService.getProducts();

  Stream<List<Sale>> get salesStream {
    return _dbService.getSales().map((sales) {
      if (_filterDate == null) return sales;
      return sales.where((sale) {
        return sale.timestamp.year == _filterDate!.year &&
            sale.timestamp.month == _filterDate!.month &&
            sale.timestamp.day == _filterDate!.day;
      }).toList();
    });
  }

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
      customDate: _saleDate,
    );

    _isProcessing = false;
    if (error == null) {
      quantityController.clear();
      customerController.clear();
      _selectedProduct = null;
      _saleDate = DateTime.now();
    }
    notifyListeners();
    return error;
  }

  Future<String?> deleteSale(Sale sale) async {
    return await _dbService.deleteSale(sale);
  }

  @override
  void dispose() {
    quantityController.dispose();
    customerController.dispose();
    super.dispose();
  }
}
