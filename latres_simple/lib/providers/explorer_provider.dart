import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class ExplorerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Character> characters = [];
  List<Character> favorites = [];
  List<Episode> episodes = [];

  bool isLoadingCharacters = false;
  bool isLoadingFavorites = false;
  bool isLoadingEpisodes = false;
  bool hasMoreCharacters = true;
  int _characterPage = 1;
  int _episodePage = 1;
  String searchQuery = '';
  String selectedStatus = 'All';
  String? errorMessage;

  Future<void> loadCharacters({bool refresh = false}) async {
    if (isLoadingCharacters) return;
    if (refresh) {
      _characterPage = 1;
      hasMoreCharacters = true;
      characters = [];
    }
    if (!hasMoreCharacters) return;

    isLoadingCharacters = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await _api.getCharacters(
        page: _characterPage,
        name: searchQuery,
        status: selectedStatus,
      );
      final items = (data['results'] as List)
          .map((item) => Character.fromJson(item))
          .toList();
      characters = refresh ? items : [...characters, ...items];
      hasMoreCharacters = data['info']?['next'] != null;
      _characterPage++;
    } catch (e) {
      errorMessage = e.toString();
      if (refresh) characters = [];
    } finally {
      isLoadingCharacters = false;
      notifyListeners();
    }
  }

  Future<void> search(String value) async {
    searchQuery = value;
    await loadCharacters(refresh: true);
  }

  Future<void> filterStatus(String value) async {
    selectedStatus = value;
    await loadCharacters(refresh: true);
  }

  Future<void> loadFavorites() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      favorites = [];
      notifyListeners();
      return;
    }
    isLoadingFavorites = true;
    notifyListeners();
    try {
      final rows = await SupabaseService.client
          .from('favorites')
          .select('character_id')
          .eq('user_id', user.id);
      final ids = rows.map<int>((row) => row['character_id'] as int).toList();
      final results = await Future.wait(ids.map(_api.getCharacter));
      favorites = results;
    } finally {
      isLoadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id) => favorites.any((item) => item.id == id);

  Future<void> toggleFavorite(Character character) async {
    final user = SupabaseService.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');

    final wasFavorite = isFavorite(character.id);
    if (wasFavorite) {
      favorites.removeWhere((item) => item.id == character.id);
    } else {
      favorites.insert(0, character);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await SupabaseService.client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('character_id', character.id);
      } else {
        await SupabaseService.client.from('favorites').insert({
          'user_id': user.id,
          'character_id': character.id,
        });
      }
    } catch (e) {
      if (wasFavorite) {
        favorites.add(character);
      } else {
        favorites.removeWhere((item) => item.id == character.id);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadEpisodes({bool refresh = false}) async {
    if (isLoadingEpisodes) return;
    if (refresh) {
      _episodePage = 1;
      episodes = [];
    }
    isLoadingEpisodes = true;
    notifyListeners();
    try {
      final data = await _api.getEpisodes(page: _episodePage);
      final items = (data['results'] as List)
          .map((item) => Episode.fromJson(item))
          .toList();
      episodes = refresh ? items : [...episodes, ...items];
      if (data['info']?['next'] != null) _episodePage++;
    } finally {
      isLoadingEpisodes = false;
      notifyListeners();
    }
  }
}
