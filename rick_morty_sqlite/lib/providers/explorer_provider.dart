import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class ExplorerProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Character> characters = [];
  List<Character> favorites = [];
  List<Episode> episodes = [];
  bool loadingCharacters = false, loadingFavorites = false, loadingEpisodes = false;
  bool hasMoreCharacters = true, hasMoreEpisodes = true;
  int _characterPage = 1, _episodePage = 1;
  String search = '', status = 'All';
  String? error;

  Future<void> loadCharacters({bool refresh = false}) async {
    if (loadingCharacters) return;
    if (refresh) {
      _characterPage = 1;
      hasMoreCharacters = true;
      characters = [];
    }
    if (!hasMoreCharacters) return;
    loadingCharacters = true;
    error = null;
    notifyListeners();
    try {
      final data = await _api.characters(page: _characterPage, name: search, status: status);
      final items = (data['results'] as List)
          .map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
      characters = refresh ? items : [...characters, ...items];
      hasMoreCharacters = data['info']?['next'] != null;
      _characterPage++;
    } catch (e) {
      error = e.toString();
    } finally {
      loadingCharacters = false;
      notifyListeners();
    }
  }

  Future<void> searchCharacters(String value) async {
    search = value;
    await loadCharacters(refresh: true);
  }

  Future<void> filterStatus(String value) async {
    status = value;
    await loadCharacters(refresh: true);
  }

  Future<void> loadFavorites(AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) {
      favorites = [];
      notifyListeners();
      return;
    }
    loadingFavorites = true;
    notifyListeners();
    try {
      final ids = await DatabaseService.instance.favoriteIds(user.id);
      favorites = await _api.charactersByIds(ids);
    } catch (e) {
      error = e.toString();
    } finally {
      loadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id) => favorites.any((e) => e.id == id);

  Future<void> toggleFavorite(Character character, AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');
    final exists = isFavorite(character.id);
    if (exists) {
      favorites.removeWhere((e) => e.id == character.id);
    } else {
      favorites.insert(0, character);
    }
    notifyListeners();
    try {
      if (exists) {
        await DatabaseService.instance.removeFavorite(user.id, character.id);
      } else {
        await DatabaseService.instance.addFavorite(user.id, character.id);
      }
    } catch (e) {
      if (exists) {
        favorites.add(character);
      } else {
        favorites.removeWhere((e) => e.id == character.id);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadEpisodes({bool refresh = false}) async {
    if (loadingEpisodes) return;
    if (refresh) {
      _episodePage = 1;
      hasMoreEpisodes = true;
      episodes = [];
    }
    if (!hasMoreEpisodes) return;
    loadingEpisodes = true;
    notifyListeners();
    try {
      final data = await _api.episodePage(_episodePage);
      final items = (data['results'] as List)
          .map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList();
      episodes = refresh ? items : [...episodes, ...items];
      hasMoreEpisodes = data['info']?['next'] != null;
      _episodePage++;
    } catch (e) {
      error = e.toString();
    } finally {
      loadingEpisodes = false;
      notifyListeners();
    }
  }
}
