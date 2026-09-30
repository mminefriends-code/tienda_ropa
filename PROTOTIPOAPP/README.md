# Tiendas Montaño — Aplicación Móvil (PROTOTIPOAPP)

**Plataforma Inteligente de Comercio Electrónico con Vestidor Virtual RA y Panel Administrativo Móvil.**
*Desarrollado para la materia Sistemas II — Universidad Autónoma Gabriel René Moreno (UAGRM)*

---

## 📱 Descripción General

`PROTOTIPOAPP` es la aplicación móvil oficial de **Tiendas Montaño**, diseñada bajo el paradigma **PUDS** y arquitectura reactiva en **Flutter + Dart**. Cumple con los requisitos del examen para soportar tanto a **Clientes** como al **Personal de Sucursal y Administradores**.

---

## 🎯 Módulos y Funcionalidades Implementadas

### 1. Modo Cliente (Tienda & Experiencia de Usuario)
* **Catálogo y Disponibilidad:** Consulta de prendas en tiempo real con filtros por categoría, temporada, tallas y colores, con existencias desglosadas por sucursal física.
* **Vestidor Virtual con Realidad Aumentada (RA) [CU24 / RF13]:** Simulación con cámara móvil y superposición de prendas, ajuste de tallas en tiempo real y registro de evaluación (*"Gusta", "Dudoso", "No gusta"*).
* **Asistente de Moda con Inteligencia Artificial [CU41 / RF25]:** Chatbot generativo que sugiere combinaciones y prendas según la ocasión, clima y temporada.
* **Reserva de Múltiples Prendas [CU28 / RF09 / RF10]:** Reserva de prendas para probador físico en sucursal con seguimiento de estado.
* **Bolsa y Checkout Digital [CU33 / CU34]:** Carrito de compras con pasarela digital integrada.

### 2. Modo Personal / Administrador (Operaciones y Sucursal)
* **Dashboard Ejecutivo & KPIs [CU44 / RF24]:** Ventas acumuladas, ticket promedio, reservas activas y existencias globales.
* **Atención de Reservas en Sucursal [CU29]:** Listado en tiempo real para marcar reservas como *Preparadas* y confirmar *Recepción del Cliente*.
* **Alertas Críticas de Inventario [CU46 / RF21]:** Monitoreo de quiebres de stock y existencias bajo mínimo por sucursal.

---

## 🏛️ Estructura del Código

```text
PROTOTIPOAPP/
├── pubspec.yaml                 # Dependencias y configuración de Flutter
├── README.md                    # Documentación del prototipo móvil
└── lib/
    ├── main.dart                # Punto de entrada MultiProvider
    ├── core/
    │   ├── constants/           # URLs y endpoints del backend NestJS
    │   ├── network/             # Cliente HTTP con interceptor JWT
    │   └── theme/               # Paleta de colores y tipografía Outfit/Inter
    ├── models/                  # Modelos de datos tipados (User, Product, Cart, etc.)
    ├── providers/               # Manejadores de estado (Auth, Catalog, Cart, etc.)
    └── screens/
        ├── auth/                # Login unificado con chips de acceso rápido
        ├── client/              # Vistas de catálogo, vestidor RA, reservas y chat IA
        ├── admin/               # Dashboard KPIs, atención de sucursal y alertas
        └── navigation/          # Barra de navegación adaptativa por rol
```

---

## 🚀 Cómo Ejecutar la Aplicación

1. **Asegúrate de que el Backend API esté corriendo:**
   ```bash
   # En la carpeta PROTOTIPO/api
   npm run start:prod
   # Escuchando en http://localhost:3000/api/v1
   ```

2. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar en emulador o dispositivo físico:**
   ```bash
   # Para emulador Android / iOS o Chrome Web
   flutter run -d chrome
   # o
   flutter run
   ```

---

## 🔑 Credenciales de Prueba Móvil

* **Administrador:** `admin@tiendasmontano.bo` (Contraseña: `admin123`)
* **Vendedor de Sucursal:** `vendedor.lapaz@tiendasmontano.bo` (Contraseña: `vend123`)
* **Cliente:** `maria.gonzales@correo.com` (Contraseña: `cliente123`)
