import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
  }

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders({bool requireAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await http.get(url, headers: _getHeaders(requireAuth: requireAuth));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await http.patch(
        url,
        headers: _getHeaders(requireAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final response = await http.delete(url, headers: _getHeaders(requireAuth: requireAuth));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = utf8.decode(response.bodyBytes);
    dynamic body;
    if (bodyString.isNotEmpty) {
      try {
        body = jsonDecode(bodyString);
      } catch (_) {
        body = bodyString;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      String message = 'Ocurrió un error en la solicitud.';
      if (body is Map && body.containsKey('message')) {
        message = body['message'] is List ? body['message'].join(', ') : body['message'].toString();
      }
      throw Exception(message);
    }
  }
}
