import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminProvider>().fetchAuditLogs());
  }

  @override
  Widget build(BuildContext context) {
    final adminP = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Auditoría'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminP.fetchAuditLogs(),
          ),
        ],
      ),
      body: adminP.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminP.auditLogs.isEmpty
              ? const Center(child: Text('No hay registros de auditoría recientes.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminP.auditLogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final log = adminP.auditLogs[index];
                    final String accion = log['accion'] ?? log['evento'] ?? 'ACCION';
                    final String tabla = log['tabla'] ?? log['modulo'] ?? 'SISTEMA';
                    final String usuario = log['usuario_email'] ?? log['email'] ?? log['usuario'] ?? 'Sistema';
                    final String fecha = log['fecha_hora'] ?? log['fecha'] ?? log['creado_en'] ?? '';
                    final String ip = log['ip'] ?? log['ip_origen'] ?? '127.0.0.1';

                    Color actionColor = AppTheme.primary;
                    if (accion.contains('INSERT') || accion.contains('CREAR')) actionColor = AppTheme.success;
                    if (accion.contains('UPDATE') || accion.contains('MODIFICAR')) actionColor = AppTheme.accent;
                    if (accion.contains('DELETE') || accion.contains('INHABILITAR') || accion.contains('ELIMINAR')) actionColor = AppTheme.danger;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: actionColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    accion.toUpperCase(),
                                    style: TextStyle(
                                      color: actionColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Text(
                                  tabla.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    usuario,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'IP: $ip',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                                Text(
                                  fecha.length > 19 ? fecha.substring(0, 19).replaceAll('T', ' ') : fecha,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                              ],
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
