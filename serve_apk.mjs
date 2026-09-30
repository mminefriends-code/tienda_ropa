import http from 'http';
import fs from 'fs';
import path from 'path';

const APK_PATH = 'c:/Users/Junior/.gemini/antigravity/scratch/PLATAFORMA-E-COMMERCE-SI2-main/PROTOTIPOAPP/build/app/outputs/flutter-apk/app-debug.apk';
const PORT = 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/download' || req.url === '/app.apk') {
    if (!fs.existsSync(APK_PATH)) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      return res.end('APK file not found.');
    }
    const stat = fs.statSync(APK_PATH);
    res.writeHead(200, {
      'Content-Type': 'application/vnd.android.package-archive',
      'Content-Length': stat.size,
      'Content-Disposition': 'attachment; filename="TiendasMontano_App.apk"',
    });
    fs.createReadStream(APK_PATH).pipe(res);
    return;
  }

  // Beautiful download page
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Descargar Tiendas Montaño Móvil</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 20px; box-sizing: border-box; }
        .card { background: white; border-radius: 24px; padding: 32px 24px; max-width: 400px; width: 100%; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.08); text-align: center; }
        .icon { width: 72px; height: 72px; background: #0f172a; border-radius: 20px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; font-size: 36px; }
        h1 { font-size: 22px; margin: 0 0 8px; font-weight: 700; }
        p { color: #64748b; font-size: 14px; margin: 0 0 24px; line-height: 1.5; }
        .btn { display: block; width: 100%; background: #4f46e5; color: white; text-decoration: none; padding: 16px; border-radius: 14px; font-weight: 600; font-size: 16px; box-sizing: border-box; transition: background 0.2s; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3); }
        .btn:active { background: #4338ca; }
        .info { margin-top: 20px; font-size: 12px; color: #94a3b8; }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="icon">👕</div>
        <h1>Tiendas Montaño Móvil</h1>
        <p>Versión con Panel Admin Completo, Seguridad, Sucursales, Control de Stock y Probador RA.</p>
        <a href="/download" class="btn">📲 Descargar e Instalar APK</a>
        <div class="info">Tamaño: ~40 MB • Compatible con Tecno Spark 20 Pro+ y Android 9+</div>
      </div>
    </body>
    </html>
  `);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`APK Download Server running at http://0.0.0.0:${PORT}`);
});
