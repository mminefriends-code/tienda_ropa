import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminProvider>().fetchRoles());
  }

  @override
  Widget build(BuildContext context) {
    final adminP = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles y Matriz de Permisos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminP.fetchRoles(),
          ),
        ],
      ),
      body: adminP.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminP.roles.isEmpty
              ? const Center(child: Text('No hay roles configurados.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminP.roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rol = adminP.roles[index];
                    final String nombreRol = rol['nombre_rol'] ?? 'Rol';
                    final String desc = rol['descripcion'] ?? 'Sin descripción';
                    final List permisos = (rol['permisos_json'] is List) ? rol['permisos_json'] : [];

                    return Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.12),
                          child: const Icon(Icons.shield_outlined, color: AppTheme.primary),
                        ),
                        title: Text(
                          nombreRol,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          desc,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Permisos Asignados:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                permisos.isEmpty
                                    ? const Text('Sin permisos especiales', style: TextStyle(color: Colors.grey, fontSize: 12))
                                    : Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: permisos.map<Widget>((p) {
                                          final bool isWildcard = p.toString() == '*';
                                          return Chip(
                                            backgroundColor: isWildcard
                                                ? AppTheme.accent.withOpacity(0.15)
                                                : Colors.grey.shade100,
                                            label: Text(
                                              isWildcard ? 'Acceso Total (*)' : p.toString(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: isWildcard ? FontWeight.bold : FontWeight.normal,
                                                color: isWildcard ? AppTheme.accent : AppTheme.textPrimary,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
