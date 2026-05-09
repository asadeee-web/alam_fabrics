import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/sale.dart';
import '../../../core/models/product.dart';
import 'reports_view_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportsViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Analytics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate and export business performance data.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                children: [
                  StreamBuilder<List<Sale>>(
                    stream: viewModel.salesStream,
                    builder: (context, snapshot) {
                      return ElevatedButton.icon(
                        onPressed: snapshot.hasData
                            ? () => viewModel.exportPDF(snapshot.data!)
                            : null,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Export PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                  StreamBuilder<List<Product>>(
                    stream: viewModel.productsStream,
                    builder: (context, snapshot) {
                      return ElevatedButton.icon(
                        onPressed: snapshot.hasData
                            ? () => viewModel.exportExcel(snapshot.data!)
                            : null,
                        icon: const Icon(Icons.table_view_rounded),
                        label: const Text('Excel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Stats Cards ─────────────────────────────────────────
          StreamBuilder<Map<String, dynamic>>(
            stream: viewModel.statsStream,
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 900
                      ? 3
                      : (constraints.maxWidth > 550 ? 2 : 1);
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.8,
                    children: [
                      _buildStatCard(
                        'Total Revenue',
                        'Rs.${(stats['totalSales'] ?? 0).toStringAsFixed(0)}',
                        Icons.account_balance_wallet_rounded,
                        Colors.indigo,
                      ),
                      _buildStatCard(
                        'Net Profit',
                        'Rs.${(stats['totalProfit'] ?? 0).toStringAsFixed(0)}',
                        Icons.show_chart_rounded,
                        const Color(0xFF10B981),
                      ),
                      _buildStatCard(
                        'Inventory Value',
                        'Rs.${(stats['totalInventoryValue'] ?? 0).toStringAsFixed(0)}',
                        Icons.inventory_rounded,
                        Colors.orange,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // ── Top Brands + Monthly Goal ────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTopBrands(viewModel)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildMonthlyGoal()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildTopBrands(viewModel),
                  const SizedBox(height: 24),
                  _buildMonthlyGoal(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTopBrands(ReportsViewModel viewModel) {
    return _buildSection(
      'Top Selling Brands',
      StreamBuilder<List<Sale>>(
        stream: viewModel.salesStream,
        builder: (context, snapshot) {
          final sales = snapshot.data ?? [];
          final brandSales = viewModel.getTopBrands(sales);
          final sorted = brandSales.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final top = sorted.take(5).toList();

          if (top.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No sales data yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return Column(
            children: List.generate(top.length, (index) {
              final entry = top[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'Rs.${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6366F1),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyGoal() {
    return _buildSection(
      'Monthly Goal',
      Column(
        children: [
          const SizedBox(height: 16),
          const SizedBox(
            height: 120,
            width: 120,
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 12,
              backgroundColor: Color(0xFFF1F5F9),
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '75% of Monthly Target',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Rs. 750,000 / Rs. 1,000,000',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
