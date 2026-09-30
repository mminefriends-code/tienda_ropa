import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdminOrEmployee => _user?.isAdminOrEmployee ?? false;

  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      _api.setToken(token);
      final email = prefs.getString('user_email') ?? '';
      final nombre = prefs.getString('user_nombre');
      final rol = prefs.getString('user_rol');
      final id = prefs.getInt('user_id') ?? 0;
      _user = UserModel(id: id, email: email, nombre: nombre, rol: rol, permisos: []);
      notifyListeners();
    }
  }

  Future<bool> login(String credencial, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post(
        ApiConstants.login,
        body: {'credencial': credencial, 'password': password},
        requireAuth: false,
      );

      final token = res['access_token'];
      final usuarioMap = res['usuario'] as Map<String, dynamic>;

      _user = UserModel.fromJson(usuarioMap);
      _api.setToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setInt('user_id', _user!.id);
      await prefs.setString('user_email', _user!.email);
      if (_user!.nombre != null) await prefs.setString('user_nombre', _user!.nombre!);
      if (_user!.rol != null) await prefs.setString('user_rol', _user!.rol!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
