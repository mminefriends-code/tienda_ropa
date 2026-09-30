import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AdminProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<dynamic> _employees = [];
  List<dynamic> _roles = [];
  List<dynamic> _branches = [];
  List<dynamic> _cities = [];
  List<dynamic> _auditLogs = [];
  List<dynamic> _stockList = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get employees => _employees;
  List<dynamic> get roles => _roles;
  List<dynamic> get branches => _branches;
  List<dynamic> get cities => _cities;
  List<dynamic> get auditLogs => _auditLogs;
  List<dynamic> get stockList => _stockList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminEmployees);
      if (res is List) {
        _employees = res;
      } else if (res is Map && res['data'] is List) {
        _employees = res['data'];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEmployee({
    required String nombre,
    required String email,
    required String rolNombre,
    required int sucursalId,
    String? telefono,
    String? passwordTemporal,
  }) async {
    try {
      await _api.post(
        ApiConstants.adminEmployees,
        body: {
          'nombre': nombre,
          'email': email,
          'rol_nombre': rolNombre,
          'sucursal_id': sucursalId,
          'telefono': telefono,
          'password_temporal': passwordTemporal ?? 'admin123',
        },
      );
      await fetchEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleEmployeeStatus(int id, bool currentlyActive) async {
    try {
      if (currentlyActive) {
        await _api.patch(
          '${ApiConstants.adminEmployees}/$id/deshabilitar',
          body: {'motivo': 'Desactivado desde App Móvil'},
        );
      } else {
        await _api.patch(
          '${ApiConstants.adminEmployees}/$id/rehabilitar',
          body: {},
        );
      }
      await fetchEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminRoles);
      if (res is List) {
        _roles = res;
      } else if (res is Map && res['data'] is List) {
        _roles = res['data'];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminBranches);
      if (res is List) {
        _branches = res;
      } else if (res is Map && res['data'] is List) {
        _branches = res['data'];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCities() async {
    try {
      final res = await _api.get(ApiConstants.adminCities);
      if (res is List) {
        _cities = res;
      } else if (res is Map && res['data'] is List) {
        _cities = res['data'];
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchAuditLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminAudit);
      if (res is List) {
        _auditLogs = res;
      } else if (res is Map && res['data'] is List) {
        _auditLogs = res['data'];
      } else if (res is Map && res['registros'] is List) {
        _auditLogs = res['registros'];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStock({int? sucursalId, String? busqueda}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final queryParams = <String, String>{};
      if (sucursalId != null) queryParams['id_sucursal'] = sucursalId.toString();
      if (busqueda != null && busqueda.isNotEmpty) queryParams['busqueda'] = busqueda;

      final queryString = queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final endpoint = '${ApiConstants.adminInventoryStock}${queryString.isNotEmpty ? "?$queryString" : ""}';

      final res = await _api.get(endpoint);
      if (res is List) {
        _stockList = res;
      } else if (res is Map && res['data'] is List) {
        _stockList = res['data'];
      } else if (res is Map && res['filas'] is List) {
        _stockList = res['filas'];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
