// lib/services/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiClient {
  String get baseUrl {
    // For Flutter Web -> your Laravel on the same machine
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    // Android emulator
    // return 'http://10.0.2.2:8000/api';
    // Windows/macOS/Linux desktop
    return 'http://127.0.0.1:8000/api';
  }

  String? _token;
  void setToken(String? t) => _token = t;

  Map<String, String> _headers({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: q);

  Future<http.Response> post(String path, Map body) =>
      http.post(_u(path), headers: _headers(), body: jsonEncode(body));

  Future<http.Response> get(String path, {Map<String, String>? query}) =>
      http.get(_u(path, query), headers: _headers(json: false));

  Future<http.Response> patch(String path, Map body) =>
      http.patch(_u(path), headers: _headers(), body: jsonEncode(body));

  Future<http.Response> delete(String path) =>
      http.delete(_u(path), headers: _headers(json: false));
}
