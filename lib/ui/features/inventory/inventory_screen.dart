import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import 'inventory_view_model.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showProductDialog(BuildContext context, {Product? product}) {
    final viewModel = Provider.of<InventoryViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final brandController = TextEditingController(
      text: product?.brandName ?? '',
    );

    final serialController = TextEditingController(
      text: product?.serialNumber ?? '',
    );

    final costController = TextEditingController(
      text: product != null ? product.costPrice.toString() : '',
    );

    final sellingController = TextEditingController(
      text: product != null ? product.sellingPrice.toString() : '',
    );

    final qtyController = TextEditingController(
      text: product != null ? product.quantity.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: isMobile ? double.infinity : 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product == null ? 'Add New Stock' : 'Edit Stock',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(
                      labelText: 'Brand Name',
                      prefixIcon: const Icon(Icons.business_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: serialController,
                    decoration: InputDecoration(
                      labelText: 'Serial / Meter',
                      prefixIcon: const Icon(Icons.qr_code_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  isMobile
                      ? Column(
                          children: [
                            TextField(
                              controller: costController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Purchase Price',
                                prefixIcon: const Icon(
                                  Icons.shopping_cart_rounded,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextField(
                              controller: sellingController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Selling Price',
                                prefixIcon: const Icon(Icons.sell_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: costController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Purchase Price',
                                  prefixIcon: const Icon(
                                    Icons.shopping_cart_rounded,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: TextField(
                                controller: sellingController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Selling Price',
                                  prefixIcon: const Icon(Icons.sell_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Quantity / Meters',
                      prefixIcon: const Icon(Icons.inventory_2_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newProduct = Product(
                              id: product?.id ?? '',
                              brandName: brandController.text.trim(),
                              itemType: 'General',
                              serialNumber: serialController.text.trim().isEmpty
                                  ? null
                                  : serialController.text.trim(),
                              costPrice:
                                  double.tryParse(costController.text) ?? 0,
                              sellingPrice:
                                  double.tryParse(sellingController.text) ?? 0,
                              quantity:
                                  double.tryParse(qtyController.text) ?? 0,
                              stockType: StockType.branded,
                            );

                            if (product == null) {
                              await viewModel.addProduct(newProduct);
                            } else {
                              await viewModel.updateProduct(newProduct);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Stock'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 700;

    final horizontalPadding = isMobile ? 16.0 : 32.0;

    return SizedBox.expand(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    0,
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Inventory Management',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Manage your stock and inventory.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: () => _showProductDialog(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('ADD NEW STOCK'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Inventory Management',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Manage your stock and inventory.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),

                            ElevatedButton.icon(
                              onPressed: () => _showProductDialog(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('ADD NEW STOCK'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                // SEARCH
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    0,
                  ),
                  child: TextField(
                    onChanged: (value) => viewModel.updateSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search by brand or serial...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // LIST
                Flexible(
                  child: StreamBuilder<List<Product>>(
                    stream: viewModel.filteredProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final products = snapshot.data ?? [];

                      if (products.isEmpty) {
                        return Center(
                          child: Text(
                            'No stock found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            24,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),

                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.inventory_2_rounded,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),

                                title: Text(
                                  p.brandName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  p.serialNumber != null &&
                                          p.serialNumber!.isNotEmpty
                                      ? 'Serial: ${p.serialNumber}'
                                      : 'No serial',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                trailing: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isMobile ? 90 : 120,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${p.quantity}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        'Rs ${p.sellingPrice.toStringAsFixed(0)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                onTap: () =>
                                    _showProductDialog(context, product: p),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
