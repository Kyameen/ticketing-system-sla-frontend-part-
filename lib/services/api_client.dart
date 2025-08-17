// lib/services/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiClient {
  // Origins
  static const String _webOrigin = 'http://127.0.0.1:8000'; // your Laravel
  static const String _desktopOrigin = 'http://127.0.0.1:8000';

  // Choose origin; we only switch for web vs. desktop here.
  String get _origin => kIsWeb ? _webOrigin : _desktopOrigin;

  // Final base including /api
  String get baseUrl => '$_origin/api';

  String? _token;
  void setToken(String? t) => _token = t;

  Map<String, String> _headers({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: q);

  static const _timeout = Duration(seconds: 10);

  Future<http.Response> get(String path, {Map<String, String>? query}) {
    return http
        .get(_u(path, query), headers: _headers(json: false))
        .timeout(_timeout);
  }

  Future<http.Response> post(String path, Map body) {
    return http
        .post(_u(path), headers: _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  Future<http.Response> patch(String path, Map body) {
    return http
        .patch(_u(path), headers: _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  Future<http.Response> delete(String path) {
    return http
        .delete(_u(path), headers: _headers(json: false))
        .timeout(_timeout);
  }
}
