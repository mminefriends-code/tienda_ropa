import pg from 'pg';
import bcrypt from 'bcrypt';

async function main() {
  const client = new pg.Client({ connectionString: 'postgresql://postgres:postgres@localhost:5432/tiendas_montano' });
  await client.connect();

  const hash = await bcrypt.hash('admin123', 10);

  // Insert or update users
  await client.query(`
    INSERT INTO usuarios (id_usuario, email, ci, password_hash, estado) VALUES
      (3, 'admin@tiendasmontano.bo', '1000001-1A', '${hash}', 'Activo'),
      (4, 'vendedor.lapaz@tiendasmontano.bo', '1000005-5E', '${hash}', 'Activo'),
      (5, 'caja.lapaz@tiendasmontano.bo', '1000009-9J', '${hash}', 'Activo'),
      (6, 'maria.gonzales@correo.com', '4567890-1K', '${hash}', 'Activo')
    ON CONFLICT (id_usuario) DO UPDATE SET password_hash = EXCLUDED.password_hash;

    INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
      (3, 1),
      (4, 2),
      (5, 3),
      (6, 4)
    ON CONFLICT DO NOTHING;

    INSERT INTO usuarios_empleados (id_empleado, usuario_id, sucursal_id, nombre, rol, telefono) VALUES
      (3, 3, 1, 'Admin Central', 'Administrador', '70011223'),
      (4, 4, 1, 'Carlos Vendedor', 'Vendedor', '70044556'),
      (5, 5, 1, 'Ana Cajera', 'Cajero', '70077889')
    ON CONFLICT (id_empleado) DO NOTHING;

    INSERT INTO clientes (id_cliente, usuario_id, nombre, telefono, direccion) VALUES
      (1, 6, 'María Gonzales', '71234567', 'Av. 6 de Agosto #123')
    ON CONFLICT (id_cliente) DO NOTHING;
  `);

  console.log('Demo users created/updated successfully!');
  const res = await client.query(`
    SELECT u.id_usuario, u.email, r.nombre_rol, ue.nombre as empleado, s.nombre as sucursal 
    FROM usuarios u 
    LEFT JOIN usuarios_roles ur ON u.id_usuario = ur.id_usuario 
    LEFT JOIN roles r ON ur.id_rol = r.id_rol 
    LEFT JOIN usuarios_empleados ue ON u.id_usuario = ue.usuario_id 
    LEFT JOIN sucursales s ON ue.sucursal_id = s.id_sucursal
  `);
  console.log(res.rows);
  await client.end();
}

main().catch(console.error);
