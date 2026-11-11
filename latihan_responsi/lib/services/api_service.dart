
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../style/app_config.dart';

class ApiService {
  ApiService._();

  static const Duration _timeout =
      Duration(seconds: 20);

  static Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}$endpoint',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)
            as Map<String, dynamic>;
      }

      throw Exception(
        'API Error: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Gagal mengakses API: $e',
      );
    }
  }

  static Future<Map<String, dynamic>>
      getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
    };

    if (status != null && status.isNotEmpty) {
      query['status'] = status.toLowerCase();
    }

    if (name != null && name.isNotEmpty) {
      query['name'] = name;
    }

    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/character',
    ).replace(queryParameters: query);

    try {
      final response = await http
          .get(uri)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)
            as Map<String, dynamic>;
      }

      throw Exception(
        'Karakter tidak ditemukan atau API gagal.',
      );
    } catch (e) {
      throw Exception(
        'Gagal mengambil data karakter: $e',
      );
    }
  }

  static Future<Map<String, dynamic>>
      getCharacterDetail(int id) async {
    return get('/character/$id');
  }

  static Future<Map<String, dynamic>>
      getEpisodes({int page = 1}) async {
    return get('/episode?page=$page');
  }
}
