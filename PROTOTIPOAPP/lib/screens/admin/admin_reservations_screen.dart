import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/reservation_provider.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReservationProvider>().fetchBranchReservations());
  }

  @override
  Widget build(BuildContext context) {
    final resProvider = context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas de Sucursal'),
      ),
      body: RefreshIndicator(
        onRefresh: () => resProvider.fetchBranchReservations(),
        child: resProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : resProvider.branchReservations.isEmpty
                ? const Center(child: Text('No hay reservas registradas en esta sucursal.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: resProvider.branchReservations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = resProvider.branchReservations[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reserva #${r.id} • ${r.clienteNombre ?? "Cliente"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  _statusBadge(r.estado),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Cita: ${r.fechaReserva} ${r.horaReserva} • ${r.sucursalNombre}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const Divider(height: 18),
                              ...r.items.map((it) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '• ${it.cantidad}x ${it.productoNombre} (Talla: ${it.talla}, Color: ${it.color})',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  )),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (r.estado == 'Pendiente')
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accent,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      icon: const Icon(Icons.checkroom, size: 16),
                                      label: const Text('Marcar Preparada', style: TextStyle(fontSize: 12)),
                                      onPressed: () => resProvider.markAsPrepared(r.id),
                                    ),
                                  if (r.estado == 'Preparada') ...[
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      icon: const Icon(Icons.how_to_reg_rounded, size: 16),
                                      label: const Text('Confirmar Recepción', style: TextStyle(fontSize: 12)),
                                      onPressed: () => resProvider.confirmDelivery(r.id),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _statusBadge(String estado) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;

    if (estado == 'Pendiente') {
      bg = AppTheme.warning.withOpacity(0.15);
      fg = AppTheme.warning;
    } else if (estado == 'Preparada' || estado == 'Completada') {
      bg = AppTheme.success.withOpacity(0.15);
      fg = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(estado, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}
