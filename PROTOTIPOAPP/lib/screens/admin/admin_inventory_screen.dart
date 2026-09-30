import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminInventoryScreen extends StatefulWidget {
  final int? initialBranchId;
  final String? branchName;

  const AdminInventoryScreen({super.key, this.initialBranchId, this.branchName});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  int? _selectedBranch;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.initialBranchId;
    Future.microtask(() {
      final p = context.read<AdminProvider>();
      p.fetchBranches();
      p.fetchStock(sucursalId: _selectedBranch);
    });
  }

  void _onFilter() {
    context.read<AdminProvider>().fetchStock(
          sucursalId: _selectedBranch,
          busqueda: _searchCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final adminP = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branchName != null ? 'Stock: ${widget.branchName}' : 'Control de Existencias & Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar por prenda o código...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _onFilter,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _onFilter(),
                ),
                if (widget.initialBranchId == null && adminP.branches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por Sucursal',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas las Sucursales')),
                      ...adminP.branches.map<DropdownMenuItem<int?>>((b) {
                        final id = b['id_sucursal'] is int ? b['id_sucursal'] : int.tryParse(b['id_sucursal'].toString());
                        return DropdownMenuItem<int?>(
                          value: id,
                          child: Text(b['nombre'] ?? 'Sucursal'),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedBranch = val);
                      _onFilter();
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: adminP.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminP.stockList.isEmpty
                    ? const Center(
                        child: Text('No hay registros de inventario coincidentes.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminP.stockList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = adminP.stockList[index];
                          final String producto = item['nombre_producto'] ?? item['producto'] ?? 'Prenda';
                          final String codigo = item['codigo_producto'] ?? item['codigo'] ?? '';
                          final String sucursal = item['sucursal'] ?? item['nombre_sucursal'] ?? 'Sucursal';
                          final String talla = item['talla'] ?? item['nombre_talla'] ?? '-';
                          final String color = item['color'] ?? item['nombre_color'] ?? '-';
                          final int stock = item['cantidad_disponible'] is int
                              ? item['cantidad_disponible']
                              : int.tryParse(item['cantidad_disponible']?.toString() ?? '0') ?? 0;
                          final bool isCritical = stock <= 2;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCritical
                                    ? AppTheme.danger.withOpacity(0.12)
                                    : AppTheme.success.withOpacity(0.12),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: isCritical ? AppTheme.danger : AppTheme.success,
                                ),
                              ),
                              title: Text(
                                producto,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                '$codigo • Talla: $talla • Color: $color\n$sucursal',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$stock uds',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isCritical ? AppTheme.danger : AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (isCritical)
                                    const Text(
                                      '¡Bajo Stock!',
                                      style: TextStyle(fontSize: 10, color: AppTheme.danger, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
