import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../sales/sales_screen.dart';
import '../reports/reports_screen.dart';
import 'main_view_model.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  final List<Widget> _screens = const [
    DashboardScreen(),
    InventoryScreen(),
    SalesScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final authService = Provider.of<AuthService>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Alam Fabrics',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => authService.signOut(),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildNavItem(
                    context,
                    viewModel,
                    0,
                    Icons.dashboard_rounded,
                    'Dashboard',
                  ),
                  _buildNavItem(
                    context,
                    viewModel,
                    1,
                    Icons.inventory_2_rounded,
                    'Inventory',
                  ),
                  _buildNavItem(
                    context,
                    viewModel,
                    2,
                    Icons.point_of_sale_rounded,
                    'Sales',
                  ),
                  _buildNavItem(
                    context,
                    viewModel,
                    3,
                    Icons.assessment_rounded,
                    'Reports',
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFF6366F1),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Admin User',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Store Manager',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMobile ? 0 : 32),
              ),
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: SizedBox.expand(
                  child: _screens[viewModel.selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF6366F1).withOpacity(0.1),
              selectedIndex: viewModel.selectedIndex,
              onDestinationSelected: (int index) {
                viewModel.setSelectedIndex(index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Inventory',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(
                    Icons.point_of_sale_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Sales',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assessment_outlined),
                  selectedIcon: Icon(
                    Icons.assessment_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Reports',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    MainViewModel viewModel,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = viewModel.selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => viewModel.setSelectedIndex(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
