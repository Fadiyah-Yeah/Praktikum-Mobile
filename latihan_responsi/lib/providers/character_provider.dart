
import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class CharacterProvider extends ChangeNotifier {
  List<Character> _characters = [];
  List<Character> _favorites = [];
  List<Episode> _episodes = [];

  Character? _selectedCharacter;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _currentPage = 1;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String? _errorMessage;

  List<Character> get characters => _characters;
  List<Character> get favorites => _favorites;
  List<Episode> get episodes => _episodes;

  Character? get selectedCharacter => _selectedCharacter;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String? get errorMessage => _errorMessage;

  bool isFavorite(int characterId) {
    return _favorites.any(
      (character) => character.id == characterId,
    );
  }

  Future<void> loadCharacters({
    bool refresh = false,
  }) async {
    if (_isLoading || _isLoadingMore) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _characters = [];
    }

    if (!_hasMore) return;

    _isLoading = _characters.isEmpty;
    _isLoadingMore = _characters.isNotEmpty;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await ApiService.getCharacters(
        page: _currentPage,
        name: _searchQuery,
        status: _selectedStatus == 'All'
            ? null
            : _selectedStatus,
      );

      final results = response['results'] as List<dynamic>? ?? [];

      final newCharacters = results
          .map((item) => Character.fromJson(item))
          .toList();

      _characters.addAll(newCharacters);

      final totalPages = response['info']?['pages'] ?? 0;

      _hasMore = _currentPage < totalPages;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchCharacters(String query) async {
    _searchQuery = query.trim();
    await loadCharacters(refresh: true);
  }

  Future<void> filterByStatus(String status) async {
    _selectedStatus = status;
    await loadCharacters(refresh: true);
  }

  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedStatus = 'All';
    await loadCharacters(refresh: true);
  }

  Future<void> loadCharacterDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCharacter = null;

    notifyListeners();

    try {
      final response = await ApiService.getCharacterDetail(id);

      _selectedCharacter = Character.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEpisodes() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await ApiService.getEpisodes();

      final results = response['results'] as List<dynamic>? ?? [];

      _episodes = results
          .map((item) => Episode.fromJson(item))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    final user = SupabaseService.currentUser;

    if (user == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('favorites')
          .select('character_id')
          .eq('user_id', user.id);

      final ids = response
          .map<int>((item) => item['character_id'] as int)
          .toList();

      if (ids.isEmpty) {
        _favorites = [];
        notifyListeners();
        return;
      }

      final characters = await Future.wait(
        ids.map(
          (id) => ApiService.getCharacterDetail(id),
        ),
      );

      _favorites = characters
          .map((item) => Character.fromJson(item))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(int characterId) async {
    final user = SupabaseService.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final alreadyFavorite = isFavorite(characterId);

    try {
      if (alreadyFavorite) {
        await SupabaseService.client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('character_id', characterId);

        _favorites.removeWhere(
          (character) => character.id == characterId,
        );
      } else {
        await SupabaseService.client
            .from('favorites')
            .insert({
          'user_id': user.id,
          'character_id': characterId,
        });

        final response =
            await ApiService.getCharacterDetail(characterId);

        _favorites.add(Character.fromJson(response));
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearSelectedCharacter() {
    _selectedCharacter = null;
    notifyListeners();
  }

  void clearData() {
    _characters = [];
    _favorites = [];
    _episodes = [];
    _selectedCharacter = null;

    _currentPage = 1;
    _hasMore = true;
    _searchQuery = '';
    _selectedStatus = 'All';
    _errorMessage = null;

    notifyListeners();
  }
}
