import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const _baseUrl = 'https://rickandmortyapi.com/api';

  Future<Map<String, dynamic>> getCharacters({
    int page = 1,
    String name = '',
    String status = '',
  }) async {
    final query = <String, String>{'page': '$page'};
    if (name.trim().isNotEmpty) query['name'] = name.trim();
    if (status.isNotEmpty && status != 'All') {
      query['status'] = status.toLowerCase();
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/character').replace(queryParameters: query),
    );
    if (response.statusCode == 404) {
      return {'results': [], 'info': {'next': null}};
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil karakter (${response.statusCode}).');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Character> getCharacter(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/character/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail karakter.');
    }
    return Character.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> getEpisodes({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/episode?page=$page'),
    );
    if (response.statusCode == 404) {
      return {'results': [], 'info': {'next': null}};
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil episode.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
