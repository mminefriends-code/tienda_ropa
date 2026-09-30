class UserModel {
  final int id;
  final String email;
  final String? nombre;
  final String? rol;
  final List<dynamic> permisos;

  UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.rol,
    required this.permisos,
  });

  bool get isAdminOrEmployee => rol == 'Administrador' || rol == 'Gerente' || rol == 'Vendedor' || rol == 'Cajero';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'],
      rol: json['rol'],
      permisos: json['permisos'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'permisos': permisos,
    };
  }
}
