import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../client/home_screen.dart';
import '../client/catalog_screen.dart';
import '../client/reservations_screen.dart';
import '../client/cart_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_reservations_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    // Vistas según rol
    final bool isStaff = auth.isAdminOrEmployee;

    final List<Widget> screens = isStaff
        ? [
            const AdminDashboardScreen(),
            const ClientCatalogScreen(),
            const AdminReservationsScreen(),
            const ClientCartScreen(),
          ]
        : [
            ClientHomeScreen(onGoToCatalog: () => setState(() => _currentIndex = 1)),
            const ClientCatalogScreen(),
            const ClientReservationsScreen(),
            const ClientCartScreen(),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.cardBorder)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withOpacity(0.12),
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(isStaff ? Icons.dashboard_outlined : Icons.home_outlined),
              selectedIcon: Icon(isStaff ? Icons.dashboard : Icons.home, color: AppTheme.primary),
              label: isStaff ? 'Dashboard' : 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view, color: AppTheme.primary),
              label: 'Catálogo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: AppTheme.primary),
              label: 'Reservas',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.itemCount > 0,
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cart.itemCount > 0,
                label: Text('${cart.itemCount}'),
                child: const Icon(Icons.shopping_bag, color: AppTheme.primary),
              ),
              label: 'Bolsa',
            ),
          ],
        ),
      ),
    );
  }
}
