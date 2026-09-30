import { Injectable, OnApplicationBootstrap, Logger } from '@nestjs/common';
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

@Injectable()
export class DatabaseInitializerService implements OnApplicationBootstrap {
  private readonly logger = new Logger(DatabaseInitializerService.name);

  constructor(private readonly dataSource: DataSource) {}

  async onApplicationBootstrap() {
    try {
      this.logger.log('Verificando inicialización de la base de datos...');

      // 1. Verificar si las tablas principales existen o crearlas
      await this.ensureSchema();

      // 2. Verificar si hay usuarios o si se requiere sembrar datos iniciales
      await this.seedInitialData();

      this.logger.log('✓ Base de datos inicializada y lista para su uso.');
    } catch (error) {
      this.logger.error('Error al inicializar la base de datos:', error);
    }
  }

  private async ensureSchema() {
    // Intentar buscar los archivos SQL si están en el sistema de archivos
    const currentDir = path.dirname(fileURLToPath(import.meta.url));
    const possiblePaths = [
      path.resolve(currentDir, '../../../BASE DE DATOS/schema.sql'),
      path.resolve(currentDir, '../../BASE DE DATOS/schema.sql'),
      path.resolve(process.cwd(), 'BASE DE DATOS/schema.sql'),
      path.resolve(process.cwd(), '../BASE DE DATOS/schema.sql'),
      path.resolve(process.cwd(), '../../BASE DE DATOS/schema.sql'),
    ];

    for (const p of possiblePaths) {
      if (fs.existsSync(p)) {
        try {
          const sql = fs.readFileSync(p, 'utf8');
          this.logger.log(`Ejecutando schema.sql desde: ${p}`);
          await this.dataSource.query(sql);
          return;
        } catch (err) {
          this.logger.warn(`Aviso al ejecutar schema.sql desde ${p}: ${(err as Error)?.message || err}`);
        }
      }
    }
  }

  private async seedInitialData() {
    const hash = await bcrypt.hash('admin123', 10);

    // 1. Roles
    await this.dataSource.query(`
      INSERT INTO roles (id_rol, nombre_rol, descripcion, permisos_json, estado) VALUES
        (1, 'Administrador', 'Acceso total del sistema', '["*"]'::jsonb, 'Activo'),
        (2, 'Gerente', 'Administra ciudades, sucursales y catalogo', '["gestionar_usuarios","gestionar_reservas","gestionar_ciudades","gestionar_catalogo","gestionar_compras","ver_reportes"]'::jsonb, 'Activo'),
        (3, 'Vendedor', 'Atiende en mostrador y procesa ventas', '["ver_catalogo","registrar_venta","procesar_pago","gestionar_reservas","gestionar_devoluciones"]'::jsonb, 'Activo'),
        (4, 'Cliente', 'Compra por la web y app movil', '["ver_catalogo","gestionar_carrito","realizar_compra","gestionar_reservas","usar_vestidor_ra"]'::jsonb, 'Activo')
      ON CONFLICT (id_rol) DO UPDATE SET permisos_json = EXCLUDED.permisos_json;
    `);

    // 2. Usuarios
    await this.dataSource.query(`
      INSERT INTO usuarios (id_usuario, email, ci, password_hash, estado, intentos_fallidos) VALUES
        (1, 'admin@tiendasmontano.bo', '1000001-1A', '${hash}', 'Activo', 0),
        (2, 'gerencia@tiendasmontano.bo', '1000002-2B', '${hash}', 'Activo', 0),
        (3, 'vendedor.lapaz@tiendasmontano.bo', '1000005-5E', '${hash}', 'Activo', 0),
        (4, 'caja.lapaz@tiendasmontano.bo', '1000009-9J', '${hash}', 'Activo', 0),
        (5, 'maria.gonzales@correo.com', '4567890-1K', '${hash}', 'Activo', 0)
      ON CONFLICT (id_usuario) DO UPDATE SET password_hash = EXCLUDED.password_hash, estado = 'Activo';
    `);

    // 3. Usuarios Roles
    await this.dataSource.query(`
      INSERT INTO usuarios_roles (id_usuario, id_rol) VALUES
        (1, 1),
        (2, 2),
        (3, 3),
        (4, 3),
        (5, 4)
      ON CONFLICT DO NOTHING;
    `);

    // 4. Ciudades y Sucursales
    await this.dataSource.query(`
      INSERT INTO ciudades (id_ciudad, nombre, pais, estado) VALUES
        (1, 'La Paz', 'Bolivia', 'Activa'),
        (2, 'Santa Cruz', 'Bolivia', 'Activa'),
        (3, 'Cochabamba', 'Bolivia', 'Activa')
      ON CONFLICT (id_ciudad) DO NOTHING;

      INSERT INTO sucursales (id_sucursal, nombre, direccion, id_ciudad, telefono, estado) VALUES
        (1, 'Sucursal Central La Paz', 'Av. 16 de Julio #1490 (El Prado)', 1, '2-2441122', 'Activa'),
        (2, 'Sucursal Santa Cruz Norte', 'Av. Cristo Redentor 4to Anillo', 2, '3-3445566', 'Activa'),
        (3, 'Sucursal Cochabamba Heroínas', 'Av. Heroínas #456', 3, '4-4223344', 'Activa')
      ON CONFLICT (id_sucursal) DO NOTHING;

      INSERT INTO usuarios_empleados (id_empleado, usuario_id, sucursal_id, nombre, rol, telefono) VALUES
        (1, 1, 1, 'Administrador Central', 'Administrador', '70011223'),
        (2, 3, 1, 'Carlos Vendedor', 'Vendedor', '70044556'),
        (3, 4, 1, 'Ana Cajera', 'Cajero', '70077889')
      ON CONFLICT (id_empleado) DO NOTHING;

      INSERT INTO clientes (id_cliente, usuario_id, nombre, telefono, direccion) VALUES
        (1, 5, 'María Gonzales', '71234567', 'Av. 6 de Agosto #123')
      ON CONFLICT (id_cliente) DO NOTHING;
    `);

    // 5. Tallas y Colores
    await this.dataSource.query(`
      INSERT INTO tallas (id_talla, nombre, orden) VALUES
        (1, 'XS', 1),
        (2, 'S', 2),
        (3, 'M', 3),
        (4, 'L', 4),
        (5, 'XL', 5),
        (6, 'XXL', 6),
        (7, 'Única', 7)
      ON CONFLICT (id_talla) DO NOTHING;

      INSERT INTO colores (id_color, nombre, codigo_hex) VALUES
        (1, 'Negro', '#000000'),
        (2, 'Blanco', '#FFFFFF'),
        (3, 'Azul Marino', '#1B2A41'),
        (4, 'Rojo Borgoña', '#800020'),
        (5, 'Verde Oliva', '#556B2F'),
        (6, 'Beige Arena', '#E8DCC4'),
        (7, 'Gris Jaspe', '#808080')
      ON CONFLICT (id_color) DO NOTHING;
    `);

    // 6. Categorías y Temporadas
    await this.dataSource.query(`
      INSERT INTO categorias (id_categoria, nombre, descripcion) VALUES
        (1, 'Poleras y Camisetas', 'Poleras de algodón pima, básicas y estampadas'),
        (2, 'Camisas y Blusas', 'Camisas formales y casuales para vestir elegante'),
        (3, 'Pantalones y Jeans', 'Jeans denim stretch y pantalones de vestir'),
        (4, 'Chaquetas y Chamarras', 'Chamarras abrigadas, cuero y bomber'),
        (5, 'Vestidos', 'Vestidos de fiesta y casuales de temporada'),
        (6, 'Ropa Deportiva', 'Conjuntos deportivos, buzos y licras')
      ON CONFLICT (id_categoria) DO NOTHING;

      INSERT INTO temporadas (id_temporada, nombre, fecha_inicio, fecha_fin, estado) VALUES
        (1, 'Colección Primavera - Verano 2026', '2026-09-01', '2027-02-28', 'Activa'),
        (2, 'Colección Permanente', NULL, NULL, 'Activa')
      ON CONFLICT (id_temporada) DO NOTHING;
    `);

    // 7. Productos de Demostración con imágenes y precios
    await this.dataSource.query(`
      INSERT INTO productos (id_producto, codigo, nombre, descripcion, id_categoria, precio_base, estado, fecha_registro) VALUES
        (1, 'POL-001', 'Polera Premium Algodón Pima', 'Polera suave de alta durabilidad, corte regular fit.', 1, 120.00, 'Disponible', NOW()),
        (2, 'CAM-002', 'Camisa Oxford Slim Fit Celeste', 'Camisa clásica para oficina o eventos casuales.', 2, 210.00, 'Disponible', NOW()),
        (3, 'JEA-003', 'Jeans Denim Clásico Azul', 'Jeans resistente de mezclilla premium con elasticidad.', 3, 280.00, 'Disponible', NOW()),
        (4, 'CHA-004', 'Chamarra Bomber Negra', 'Chamarra impermeable con forro térmico y cierres metálicos.', 4, 450.00, 'Disponible', NOW()),
        (5, 'VES-005', 'Vestido Floral de Verano', 'Vestido fresco con estampado floral y ajuste a la cintura.', 5, 290.00, 'Disponible', NOW()),
        (6, 'DEP-006', 'Conjunto Deportivo Tech Fleece', 'Buzo y polerón térmico transpirable para entrenamiento.', 6, 350.00, 'Disponible', NOW())
      ON CONFLICT (id_producto) DO NOTHING;

      -- Imágenes
      INSERT INTO producto_imagenes (id_producto, url, orden, es_principal) VALUES
        (1, 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80', 1, true),
        (2, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&auto=format&fit=crop&q=80', 1, true),
        (3, 'https://images.unsplash.com/photo-1542272604-780c96856592?w=800&auto=format&fit=crop&q=80', 1, true),
        (4, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80', 1, true),
        (5, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&auto=format&fit=crop&q=80', 1, true),
        (6, 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&auto=format&fit=crop&q=80', 1, true)
      ON CONFLICT DO NOTHING;

      -- Variantes Talla / Color
      INSERT INTO producto_talla_color (id_ptc, id_producto, id_talla, id_color, estado_stock) VALUES
        (1, 1, 2, 1, 'Disponible'),
        (2, 1, 3, 1, 'Disponible'),
        (3, 1, 4, 1, 'Disponible'),
        (4, 1, 3, 2, 'Disponible'),
        (5, 2, 3, 3, 'Disponible'),
        (6, 2, 4, 3, 'Disponible'),
        (7, 3, 3, 3, 'Disponible'),
        (8, 3, 4, 3, 'Disponible'),
        (9, 4, 3, 1, 'Disponible'),
        (10, 4, 4, 1, 'Disponible'),
        (11, 5, 2, 4, 'Disponible'),
        (12, 5, 3, 4, 'Disponible'),
        (13, 6, 3, 1, 'Disponible'),
        (14, 6, 4, 1, 'Disponible')
      ON CONFLICT (id_ptc) DO NOTHING;

      -- Stock en Sucursales
      INSERT INTO inventario_stock (id_ptc, id_sucursal, stock_actual, stock_minimo) VALUES
        (1, 1, 25, 5),
        (2, 1, 40, 10),
        (3, 1, 30, 8),
        (4, 1, 20, 5),
        (5, 1, 15, 4),
        (6, 1, 22, 6),
        (7, 1, 18, 5),
        (8, 1, 24, 6),
        (9, 1, 12, 3),
        (10, 1, 16, 4),
        (11, 1, 14, 4),
        (12, 1, 19, 5),
        (13, 1, 20, 5),
        (14, 1, 25, 6)
      ON CONFLICT (id_ptc, id_sucursal) DO UPDATE SET stock_actual = EXCLUDED.stock_actual;
    `);

    // Ajustar secuencias seriales
    await this.dataSource.query(`
      SELECT setval('roles_id_rol_seq', (SELECT COALESCE(MAX(id_rol), 1) FROM roles));
      SELECT setval('usuarios_id_usuario_seq', (SELECT COALESCE(MAX(id_usuario), 1) FROM usuarios));
      SELECT setval('ciudades_id_ciudad_seq', (SELECT COALESCE(MAX(id_ciudad), 1) FROM ciudades));
      SELECT setval('sucursales_id_sucursal_seq', (SELECT COALESCE(MAX(id_sucursal), 1) FROM sucursales));
      SELECT setval('usuarios_empleados_id_empleado_seq', (SELECT COALESCE(MAX(id_empleado), 1) FROM usuarios_empleados));
      SELECT setval('clientes_id_cliente_seq', (SELECT COALESCE(MAX(id_cliente), 1) FROM clientes));
      SELECT setval('tallas_id_talla_seq', (SELECT COALESCE(MAX(id_talla), 1) FROM tallas));
      SELECT setval('colores_id_color_seq', (SELECT COALESCE(MAX(id_color), 1) FROM colores));
      SELECT setval('categorias_id_categoria_seq', (SELECT COALESCE(MAX(id_categoria), 1) FROM categorias));
      SELECT setval('temporadas_id_temporada_seq', (SELECT COALESCE(MAX(id_temporada), 1) FROM temporadas));
      SELECT setval('productos_id_producto_seq', (SELECT COALESCE(MAX(id_producto), 1) FROM productos));
      SELECT setval('producto_talla_color_id_ptc_seq', (SELECT COALESCE(MAX(id_ptc), 1) FROM producto_talla_color));
    `);
  }
}
