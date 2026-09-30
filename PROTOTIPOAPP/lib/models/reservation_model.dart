class ReservationItemModel {
  final int id;
  final int idPtc;
  final String productoNombre;
  final String talla;
  final String color;
  final int cantidad;
  final String? imagenUrl;

  ReservationItemModel({
    required this.id,
    required this.idPtc,
    required this.productoNombre,
    required this.talla,
    required this.color,
    required this.cantidad,
    this.imagenUrl,
  });

  factory ReservationItemModel.fromJson(Map<String, dynamic> json) {
    return ReservationItemModel(
      id: json['id_reserva_item'] ?? 0,
      idPtc: json['id_ptc'] ?? 0,
      productoNombre: json['producto_nombre'] ?? json['nombre'] ?? 'Prenda',
      talla: json['talla'] ?? '',
      color: json['color'] ?? '',
      cantidad: json['cantidad'] ?? 1,
      imagenUrl: json['imagen_url'],
    );
  }
}

class ReservationModel {
  final int id;
  final int idSucursal;
  final String sucursalNombre;
  final String fechaReserva;
  final String horaReserva;
  final String estado; // Pendiente, Preparada, Completada, Cancelada
  final String? clienteNombre;
  final String? clienteEmail;
  final List<ReservationItemModel> items;

  ReservationModel({
    required this.id,
    required this.idSucursal,
    required this.sucursalNombre,
    required this.fechaReserva,
    required this.horaReserva,
    required this.estado,
    this.clienteNombre,
    this.clienteEmail,
    required this.items,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ReservationModel(
      id: json['id_reserva'] ?? 0,
      idSucursal: json['id_sucursal'] ?? 0,
      sucursalNombre: json['sucursal_nombre'] ?? json['sucursal'] ?? '',
      fechaReserva: json['fecha_reserva'] ?? '',
      horaReserva: json['hora_reserva'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
      clienteNombre: json['cliente_nombre'] ?? json['cliente'],
      clienteEmail: json['cliente_email'],
      items: rawItems.map((e) => ReservationItemModel.fromJson(e)).toList(),
    );
  }
}
