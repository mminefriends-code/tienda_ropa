import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final p = context.read<AdminProvider>();
      p.fetchEmployees();
      p.fetchRoles();
      p.fetchBranches();
    });
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'admin123');
    String selectedRole = 'Vendedor';
    int selectedBranch = 1;

    final adminP = context.read<AdminProvider>();
    final branches = adminP.branches;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nuevo Usuario / Empleado',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Institucional',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono / Celular',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol Asignado',
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                        DropdownMenuItem(value: 'Gerente', child: Text('Gerente')),
                        DropdownMenuItem(value: 'Encargado de Sucursal', child: Text('Encargado de Sucursal')),
                        DropdownMenuItem(value: 'Vendedor', child: Text('Vendedor')),
                        DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: branches.isNotEmpty ? (branches.first['id_sucursal'] ?? 1) : 1,
                      decoration: const InputDecoration(
                        labelText: 'Sucursal de Operación',
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                      items: branches.map<DropdownMenuItem<int>>((b) {
                        return DropdownMenuItem<int>(
                          value: b['id_sucursal'] is int ? b['id_sucursal'] : int.tryParse(b['id_sucursal'].toString()) ?? 1,
                          child: Text(b['nombre'] ?? 'Sucursal'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedBranch = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña Temporal',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Registrar Usuario'),
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor completa nombre y email.')),
                          );
                          return;
                        }
                        final ok = await adminP.createEmployee(
                          nombre: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          rolNombre: selectedRole,
                          sucursalId: selectedBranch,
                          telefono: phoneCtrl.text.trim(),
                          passwordTemporal: passCtrl.text.trim(),
                        );
                        if (ok && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Usuario registrado exitosamente')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminP = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios & Personal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminP.fetchEmployees(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Nuevo Usuario', style: TextStyle(color: Colors.white)),
        onPressed: _showAddUserDialog,
      ),
      body: adminP.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminP.employees.isEmpty
              ? const Center(
                  child: Text('No se encontraron usuarios registrados.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: adminP.employees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final emp = adminP.employees[index];
                    final bool isActive = emp['activo'] ?? (emp['fecha_baja'] == null);
                    final String rol = emp['rol'] ?? emp['nombre_rol'] ?? 'Empleado';
                    final String nombre = emp['nombre'] ?? 'Sin Nombre';
                    final String email = emp['email'] ?? '';
                    final String sucursal = emp['sucursal'] ?? emp['sucursal_nombre'] ?? 'Sucursal Central';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: isActive
                                  ? AppTheme.primary.withOpacity(0.12)
                                  : AppTheme.danger.withOpacity(0.12),
                              child: Text(
                                nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U',
                                style: TextStyle(
                                  color: isActive ? AppTheme.primary : AppTheme.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nombre,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppTheme.success.withOpacity(0.15)
                                              : AppTheme.danger.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isActive ? 'ACTIVO' : 'INACTIVO',
                                          style: TextStyle(
                                            color: isActive ? AppTheme.success : AppTheme.danger,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Rol: $rol',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          sucursal,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) async {
                                final id = emp['id_empleado'] ?? emp['id_usuario'];
                                if (val == 'toggle' && id != null) {
                                  await adminP.toggleEmployeeStatus(id, isActive);
                                }
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(isActive ? 'Deshabilitar' : 'Reactivar'),
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
