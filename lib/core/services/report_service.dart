import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class ReportService {
  static Future<void> generateSalesReportPDF(List<Sale> sales) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Alam Fabrics - Sales Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(dateFormat.format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              'Date',
              'Product',
              'Customer',
              'Qty',
              'Price',
              'Total',
              'Profit',
            ],
            data: sales
                .map(
                  (sale) => [
                    dateFormat.format(sale.timestamp),
                    '${sale.brandName} - ${sale.productName}',
                    sale.customerName ?? '-',
                    sale.quantitySold.toString(),
                    sale.sellingPrice.toStringAsFixed(2),
                    sale.totalPrice.toStringAsFixed(2),
                    sale.profit.toStringAsFixed(2),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Sales: Rs.${sales.fold(0.0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Total Profit: Rs.${sales.fold(0.0, (sum, item) => sum + item.profit).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateInventoryExcel(List<Product> products) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventory Report'];
    excel.delete('Sheet1');

    // Headers
    sheetObject.appendRow([
      TextCellValue('Brand'),
      TextCellValue('Item Type'),
      TextCellValue('Stock Type'),
      TextCellValue('Serial Number'),
      TextCellValue('Cost Price'),
      TextCellValue('Selling Price'),
      TextCellValue('Quantity/Meters'),
      TextCellValue('Value (Cost)'),
    ]);

    for (var product in products) {
      sheetObject.appendRow([
        TextCellValue(product.brandName),
        TextCellValue(product.itemType),
        TextCellValue(product.stockType.name),
        TextCellValue(product.serialNumber ?? '-'),
        DoubleCellValue(product.costPrice),
        DoubleCellValue(product.sellingPrice),
        DoubleCellValue(product.quantity),
        DoubleCellValue(product.quantity * product.costPrice),
      ]);
    }

    // Since this is a web/desktop app, we'll trigger a download in a real app.
    // For this environment, we'll just save it to a temporary path or provide the bytes.
    // In a Flutter web app, you'd use universal_html or similar.
    final bytes = excel.encode();
    if (bytes != null) {
      // In a real scenario, you'd save/download this.
      print("Excel generated: ${bytes.length} bytes");
    }
  }

  static Future<void> printReceipt(Sale sale) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'ALAM FABRICS',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Main Bazar, City Name'),
            pw.Text('Phone: 0300-1234567'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date:'),
                pw.Text(dateFormat.format(sale.timestamp)),
              ],
            ),
            if (sale.customerName != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('Customer:'), pw.Text(sale.customerName!)],
              ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.Row(
              children: [
                pw.Expanded(flex: 3, child: pw.Text('Item')),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text('Qty', textAlign: pw.TextAlign.center),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text('Total', textAlign: pw.TextAlign.right),
                ),
              ],
            ),
            pw.Divider(),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('${sale.brandName} ${sale.productName}'),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    sale.quantitySold.toString(),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Rs.${sale.totalPrice.toStringAsFixed(0)}',
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GRAND TOTAL',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Rs.${sale.totalPrice.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Thank you for shopping!',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
