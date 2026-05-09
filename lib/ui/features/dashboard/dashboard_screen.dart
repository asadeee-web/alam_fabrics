import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import 'dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back! Here is what\'s happening today.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Stats Grid
          StreamBuilder<Map<String, dynamic>>(
            stream: viewModel.statsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data ?? {};
              final screenWidth = MediaQuery.of(context).size.width;
              final cols = screenWidth > 1200
                  ? 3
                  : (screenWidth > 700 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.2,
                children: [
                  _buildStatCard(
                    'Total Sales',
                    'Rs.${(stats['totalSales'] ?? 0).toStringAsFixed(0)}',
                    Icons.payments_rounded,
                    const [Color(0xFF6366F1), Color(0xFF4338CA)],
                  ),
                  _buildStatCard(
                    'Total Profit',
                    'Rs.${(stats['totalProfit'] ?? 0).toStringAsFixed(0)}',
                    Icons.trending_up_rounded,
                    const [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  _buildStatCard(
                    'Inventory Value',
                    'Rs.${(stats['totalInventoryValue'] ?? 0).toStringAsFixed(0)}',
                    Icons.inventory_2_rounded,
                    const [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  _buildStatCard(
                    'Today\'s Sales',
                    'Rs.${(stats['todaySales'] ?? 0).toStringAsFixed(0)}',
                    Icons.today_rounded,
                    const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  _buildStatCard(
                    'Total Products',
                    '${stats['totalProducts'] ?? 0}',
                    Icons.shopping_bag_rounded,
                    const [Color(0xFFEC4899), Color(0xFFDB2777)],
                  ),
                  _buildStatCard(
                    'Low Stock Alerts',
                    '${stats['lowStockCount'] ?? 0}',
                    Icons.warning_amber_rounded,
                    const [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 48),

          // Low Stock Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low Stock Alerts',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<Product>>(
            stream: viewModel.lowStockProducts,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final lowStockItems = snapshot.data!;

              if (lowStockItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 48,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'All items are well stocked!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockItems.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade50),
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Type: ${item.itemType}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity} units left',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Restock soon',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Icon(icon, size: 90, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
