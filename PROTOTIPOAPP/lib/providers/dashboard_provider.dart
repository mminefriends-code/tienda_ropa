import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  DashboardKpisModel? _kpis;
  List<CriticalAlertModel> _criticalAlerts = [];
  bool _isLoading = false;
  String? _error;

  DashboardKpisModel? get kpis => _kpis;
  List<CriticalAlertModel> get criticalAlerts => _criticalAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchKpis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get(ApiConstants.dashboardKpis);
      _kpis = DashboardKpisModel.fromJson(res);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCriticalAlerts() async {
    try {
      final res = await _api.get(ApiConstants.alertasCriticas);
      final quiebres = res['quiebres']?['items'] as List<dynamic>? ?? [];
      _criticalAlerts = quiebres.map((e) => CriticalAlertModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }
}
