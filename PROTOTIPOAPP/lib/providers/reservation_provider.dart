import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<ReservationModel> _myReservations = [];
  List<ReservationModel> _branchReservations = [];
  bool _isLoading = false;
  String? _error;

  List<ReservationModel> get myReservations => _myReservations;
  List<ReservationModel> get branchReservations => _branchReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get(ApiConstants.misReservas);
      final rawList = res as List<dynamic>? ?? [];
      _myReservations = rawList.map((e) => ReservationModel.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBranchReservations({int? idSucursal}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = idSucursal != null
          ? '${ApiConstants.reservasSucursal}/$idSucursal'
          : ApiConstants.reservasSucursal;
      final res = await _api.get(url);
      final rawList = res as List<dynamic>? ?? [];
      _branchReservations = rawList.map((e) => ReservationModel.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReservation({
    required int idSucursal,
    required String fecha,
    required String hora,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post(
        ApiConstants.reservas,
        body: {
          'id_sucursal': idSucursal,
          'fecha_reserva': fecha,
          'hora_reserva': hora,
          'items': items,
        },
      );
      _isLoading = false;
      await fetchMyReservations();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsPrepared(int idReserva) async {
    try {
      await _api.patch(ApiConstants.prepararReserva(idReserva));
      await fetchBranchReservations();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmDelivery(int idReserva) async {
    try {
      await _api.patch(ApiConstants.confirmarRecepcionReserva(idReserva));
      await fetchBranchReservations();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
