import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import 'admin_inventory_screen.dart';

class AdminBranchesScreen extends StatefulWidget {
  const AdminBranchesScreen({super.key});

  @override
  State<AdminBranchesScreen> createState() => _AdminBranchesScreenState();
}

class _AdminBranchesScreenState extends State<AdminBranchesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<AdminProvider>();
      p.fetchBranches();
      p.fetchCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminP = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucursales & Almacenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminP.fetchBranches(),
          ),
        ],
      ),
      body: adminP.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminP.branches.isEmpty
              ? const Center(child: Text('No hay sucursales registradas.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminP.branches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final branch = adminP.branches[index];
                    final String nombre = branch['nombre'] ?? 'Sucursal';
                    final String ciudad = branch['ciudad'] ?? branch['nombre_ciudad'] ?? 'Bolivia';
                    final String direccion = branch['direccion'] ?? 'Sin dirección';
                    final String telefono = branch['telefono'] ?? 'Sin teléfono';
                    final String estado = branch['estado'] ?? 'Activa';
                    final bool isActive = estado.toLowerCase() == 'activa';
                    final int branchId = branch['id_sucursal'] is int
                        ? branch['id_sucursal']
                        : int.tryParse(branch['id_sucursal'].toString()) ?? 1;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primary.withOpacity(0.12),
                                  radius: 22,
                                  child: const Icon(Icons.storefront, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            ciudad,
                                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppTheme.success.withOpacity(0.15) : AppTheme.danger.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    estado.toUpperCase(),
                                    style: TextStyle(
                                      color: isActive ? AppTheme.success : AppTheme.danger,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.home_work_outlined, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(direccion, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(telefono, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(38),
                              ),
                              icon: const Icon(Icons.inventory_2_outlined, size: 16),
                              label: const Text('Consultar Stock en esta Sucursal', style: TextStyle(fontSize: 13)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminInventoryScreen(
                                      initialBranchId: branchId,
                                      branchName: nombre,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
