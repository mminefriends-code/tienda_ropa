import pg from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function runSeed() {
  const dbUrl = process.env.DATABASE_URL || process.argv[2];
  if (!dbUrl) {
    console.error('Error: Proporciona la DATABASE_URL como argumento o variable de entorno.');
    console.log('Ejemplo: node seed_cloud.mjs "postgresql://usuario:pass@host/db"');
    process.exit(1);
  }

  console.log('Conectando a PostgreSQL...');
  const client = new pg.Client({
    connectionString: dbUrl,
    ssl: { rejectUnauthorized: false },
  });

  await client.connect();
  console.log('✓ Conectado a la base de datos.');

  const schemaPath = path.resolve(__dirname, '../../BASE DE DATOS/schema.sql');
  const poblacionPath = path.resolve(__dirname, '../../BASE DE DATOS/poblacion_datos.sql');
  const imagenesPath = path.resolve(__dirname, '../../BASE DE DATOS/seed_imagenes_productos.sql');

  if (fs.existsSync(schemaPath)) {
    console.log('Ejecutando schema.sql (creando tablas y relaciones)...');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await client.query(schemaSql);
    console.log('✓ Tablas creadas exitosamente.');
  }

  if (fs.existsSync(poblacionPath)) {
    console.log('Ejecutando poblacion_datos.sql (insertando productos, tallas, colores, stock)...');
    const poblacionSql = fs.readFileSync(poblacionPath, 'utf8');
    await client.query(poblacionSql);
    console.log('✓ Datos base insertados.');
  }

  if (fs.existsSync(imagenesPath)) {
    console.log('Ejecutando seed_imagenes_productos.sql...');
    const imagenesSql = fs.readFileSync(imagenesPath, 'utf8');
    await client.query(imagenesSql);
    console.log('✓ Imágenes de productos insertadas.');
  }

  // Ensure demo admin passwords are set to admin123
  console.log('Configurando contraseñas de demostración (admin123)...');
  const bcrypt = await import('bcrypt');
  const hash = await bcrypt.default.hash('admin123', 10);
  await client.query(`
    UPDATE usuarios SET password_hash = '${hash}', estado = 'Activo' WHERE email IN (
      'admin@tiendasmontano.bo',
      'vendedor.lapaz@tiendasmontano.bo',
      'caja.lapaz@tiendasmontano.bo',
      'maria.gonzales@correo.com'
    );
  `);
  console.log('✓ Usuarios de demostración listos (admin123).');

  await client.end();
  console.log('🎉 ¡Base de datos en la nube poblada al 100% con éxito!');
}

runSeed().catch(err => {
  console.error('Error al poblar la base de datos:', err);
  process.exit(1);
});
