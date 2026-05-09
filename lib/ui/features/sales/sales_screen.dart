import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/report_service.dart';
import '../../../core/models/product.dart';
import '../../../core/models/sale.dart';
import 'sales_view_model.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SalesViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      body: isDesktop
          ? _buildDesktopLayout(context, viewModel)
          : _buildMobileLayout(context, viewModel),
    );
  }

  // ── Desktop: Side-by-side form + history ──────────────────────
  Widget _buildDesktopLayout(BuildContext context, SalesViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSaleForm(context, viewModel)),
        const SizedBox(width: 32),
        Expanded(child: _buildSalesHistory(context, viewModel)),
      ],
    );
  }

  // ── Mobile: Scrollable form, then history list ──────────────────
  Widget _buildMobileLayout(BuildContext context, SalesViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSaleForm(context, viewModel),
          const SizedBox(height: 40),
          _buildSalesHistoryMobile(context, viewModel),
        ],
      ),
    );
  }

  // ── New Sale Form ──────────────────────────────────────────────
  Widget _buildSaleForm(BuildContext context, SalesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Sale',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record a new transaction.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: viewModel.customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Product',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<Product>>(
                  stream: viewModel.productsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final products = snapshot.data ?? [];

                    return DropdownButtonFormField<Product>(
                      value: viewModel.selectedProduct,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select a product',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.brandName} (${p.quantity} ${p.stockType == StockType.meter ? 'mtr' : 'pcs'})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => viewModel.setSelectedProduct(val),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quantity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: viewModel.quantityController,
                  decoration: InputDecoration(
                    labelText:
                        viewModel.selectedProduct?.stockType == StockType.meter
                        ? 'Meters to Sell'
                        : 'Quantity to Sell',
                    prefixIcon: const Icon(Icons.add_shopping_cart_rounded),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => viewModel.notify(),
                ),

                // Price Summary
                if (viewModel.selectedProduct != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          'Unit Price',
                          'Rs.${viewModel.selectedProduct!.sellingPrice.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        _summaryRow(
                          'Profit',
                          'Rs.${((double.tryParse(viewModel.quantityController.text) ?? 0) * (viewModel.selectedProduct!.sellingPrice - viewModel.selectedProduct!.costPrice)).toStringAsFixed(0)}',
                          color: const Color(0xFF10B981),
                        ),
                        const Divider(height: 24),
                        _summaryRow(
                          'Total',
                          'Rs.${((double.tryParse(viewModel.quantityController.text) ?? 0) * viewModel.selectedProduct!.sellingPrice).toStringAsFixed(0)}',
                          large: true,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: viewModel.isProcessing
                        ? null
                        : () async {
                            final error = await viewModel.recordSale();
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sale recorded successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: viewModel.isProcessing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'COMPLETE TRANSACTION',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop Sales History (uses Expanded via parent Row) ────────
  Widget _buildSalesHistory(BuildContext context, SalesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sales',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade900,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Export CSV',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Latest transactions history.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildSalesList(context, viewModel)),
        ],
      ),
    );
  }

  // ── Mobile Sales History (no Expanded, uses shrinkWrap) ────────
  Widget _buildSalesHistoryMobile(
    BuildContext context,
    SalesViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sales',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Sale>>(
          stream: viewModel.salesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final sales = snapshot.data ?? [];
            if (sales.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sales.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade50),
                itemBuilder: (context, index) => _buildSaleTile(sales[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Scrollable list for desktop ─────────────────────────────────
  Widget _buildSalesList(BuildContext context, SalesViewModel viewModel) {
    return StreamBuilder<List<Sale>>(
      stream: viewModel.salesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sales = snapshot.data ?? [];
        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 72,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions yet',
                  style: TextStyle(color: Colors.grey, fontSize: 17),
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ListView.separated(
              itemCount: sales.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade50),
              itemBuilder: (context, index) => _buildSaleTile(sales[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaleTile(Sale sale) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981)),
      ),
      title: Text(
        sale.productName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        DateFormat('MMM dd, yyyy • hh:mm a').format(sale.timestamp),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rs.${sale.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.print_outlined,
              size: 18,
              color: Color(0xFF6366F1),
            ),
            onPressed: () => ReportService.printReceipt(sale),
            tooltip: 'Print Receipt',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.grey.shade700,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            fontSize: large ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: large ? 20 : 14,
          ),
        ),
      ],
    );
  }
}
