class DashboardKpisModel {
  final double ventasTotales;
  final int nroVentas;
  final double ticketPromedio;
  final int existenciasDisponibles;
  final int existenciasReservadas;
  final int reservasPendientes;
  final int reservasTotales;
  final int alertasStockBajo;

  DashboardKpisModel({
    required this.ventasTotales,
    required this.nroVentas,
    required this.ticketPromedio,
    required this.existenciasDisponibles,
    required this.existenciasReservadas,
    required this.reservasPendientes,
    required this.reservasTotales,
    required this.alertasStockBajo,
  });

  factory DashboardKpisModel.fromJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? json;
    return DashboardKpisModel(
      ventasTotales: (kpis['ventas_totales'] as num?)?.toDouble() ?? 0.0,
      nroVentas: kpis['nro_ventas'] ?? 0,
      ticketPromedio: (kpis['ticket_promedio'] as num?)?.toDouble() ?? 0.0,
      existenciasDisponibles: kpis['existencias_disponibles'] ?? 0,
      existenciasReservadas: kpis['existencias_reservadas'] ?? 0,
      reservasPendientes: kpis['reservas_pendientes'] ?? 0,
      reservasTotales: kpis['reservas_totales'] ?? 0,
      alertasStockBajo: kpis['alertas_stock_bajo'] ?? 0,
    );
  }
}

class CriticalAlertModel {
  final int idPtc;
  final String producto;
  final String talla;
  final String color;
  final String categoria;
  final String sucursal;
  final int cantidadDisponible;
  final int stockMinimo;

  CriticalAlertModel({
    required this.idPtc,
    required this.producto,
    required this.talla,
    required this.color,
    required this.categoria,
    required this.sucursal,
    required this.cantidadDisponible,
    required this.stockMinimo,
  });

  factory CriticalAlertModel.fromJson(Map<String, dynamic> json) {
    return CriticalAlertModel(
      idPtc: json['id_ptc'] ?? 0,
      producto: json['producto'] ?? '',
      talla: json['talla'] ?? '',
      color: json['color'] ?? '',
      categoria: json['categoria'] ?? '',
      sucursal: json['sucursal'] ?? '',
      cantidadDisponible: json['cantidad_disponible'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 0,
    );
  }
}
