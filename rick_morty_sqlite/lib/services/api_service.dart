import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const base = 'https://rickandmortyapi.com/api';

  Future<Map<String, dynamic>> characters({
    int page = 1, String name = '', String status = 'All',
  }) async {
    final q = <String, String>{'page': '$page'};
    if (name.trim().isNotEmpty) q['name'] = name.trim();
    if (status != 'All') q['status'] = status.toLowerCase();
    final r = await http.get(Uri.parse('$base/character').replace(queryParameters: q));
    if (r.statusCode == 404) return {'results': [], 'info': {'next': null}};
    if (r.statusCode != 200) throw Exception('Gagal mengambil karakter. Periksa internet.');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> episodePage(int page) async {
    final r = await http.get(Uri.parse('$base/episode?page=$page'));
    if (r.statusCode == 404) return {'results': [], 'info': {'next': null}};
    if (r.statusCode != 200) throw Exception('Gagal mengambil episode. Periksa internet.');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<Character>> charactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final r = await http.get(Uri.parse('$base/character/${ids.join(',')}'));
    if (r.statusCode != 200) throw Exception('Gagal memuat favorite.');
    final decoded = jsonDecode(r.body);
    final list = decoded is List ? decoded : [decoded];
    return list.map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
  }
}
