import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/sale.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/report_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final DatabaseService _dbService;

  ReportsViewModel(this._dbService);

  Stream<List<Sale>> get salesStream => _dbService.getSales();
  Stream<List<Product>> get productsStream => _dbService.getProducts();
  Stream<Map<String, dynamic>> get statsStream =>
      _dbService.getDashboardStats();

  void exportPDF(List<Sale> sales) {
    ReportService.generateSalesReportPDF(sales);
  }

  void exportExcel(List<Product> products) {
    ReportService.generateInventoryExcel(products);
  }

  Map<String, double> getTopBrands(List<Sale> sales) {
    final Map<String, double> brandSales = {};
    for (final s in sales) {
      brandSales[s.brandName] = (brandSales[s.brandName] ?? 0) + s.totalPrice;
    }
    return brandSales;
  }
}
