class ProductModel {
  final int id;
  final String codigo;
  final String nombre;
  final double precioConIva;
  final double precioBase;
  final double porcentajeIva;
  final double precioFinal;
  final double descuento;
  final bool destacado;
  final String? categoria;
  final String? imagenPrincipal;
  final List<String> tallas;
  final List<String> colores;

  ProductModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precioConIva,
    required this.precioBase,
    required this.porcentajeIva,
    required this.precioFinal,
    required this.descuento,
    required this.destacado,
    this.categoria,
    this.imagenPrincipal,
    required this.tallas,
    required this.colores,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id_producto'] is int ? json['id_producto'] : int.tryParse(json['id_producto'].toString()) ?? 0,
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      precioConIva: (json['precio_con_iva'] as num?)?.toDouble() ?? 0.0,
      precioBase: (json['precio_base'] as num?)?.toDouble() ?? 0.0,
      porcentajeIva: (json['porcentaje_iva'] as num?)?.toDouble() ?? 13.0,
      precioFinal: (json['precio_final'] as num?)?.toDouble() ?? (json['precio_con_iva'] as num?)?.toDouble() ?? 0.0,
      descuento: (json['descuento'] as num?)?.toDouble() ?? 0.0,
      destacado: json['destacado'] == true,
      categoria: json['categoria'],
      imagenPrincipal: json['imagen_principal'],
      tallas: (json['tallas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      colores: (json['colores'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class BranchAvailability {
  final int idSucursal;
  final String nombre;
  final String direccion;
  final String ciudad;
  final List<StockLine> lineas;

  BranchAvailability({
    required this.idSucursal,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.lineas,
  });

  factory BranchAvailability.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lineas'] as List<dynamic>? ?? [];
    return BranchAvailability(
      idSucursal: json['id_sucursal'] ?? 0,
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? '',
      lineas: rawLines.map((e) => StockLine.fromJson(e)).toList(),
    );
  }
}

class StockLine {
  final int idPtc;
  final String talla;
  final String color;
  final int disponible;
  final int reservada;

  StockLine({
    required this.idPtc,
    required this.talla,
    required this.color,
    required this.disponible,
    required this.reservada,
  });

  factory StockLine.fromJson(Map<String, dynamic> json) {
    return StockLine(
      idPtc: json['id_ptc'] ?? 0,
      talla: json['talla'] ?? '',
      color: json['color'] ?? '',
      disponible: json['disponible'] ?? 0,
      reservada: json['reservada'] ?? 0,
    );
  }
}
