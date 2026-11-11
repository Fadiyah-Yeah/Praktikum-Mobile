
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/character_provider.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/character_card.dart';

import 'detail_screen.dart';
import 'episode_screen.dart';
import 'home_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadFavorites();
    });
  }

  void _navigateToTab(int index) {
    if (index == 1) return;

    final page = index == 0
        ? const HomeScreen()
        : const EpisodeScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: provider.favorites.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoriteList(provider),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavbar(
            currentIndex: 1,
            onTap: _navigateToTab,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 65,
          width: double.infinity,
          child: Image.asset(
            'asset/images/splash_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        SizedBox(
          height: 55,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Favorite',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF302522),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'asset/characters/Morty.png',
                  width: 125,
                  height: 125,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                Positioned(
                  top: -12,
                  right: -34,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      border: Border.all(
                        color: const Color(0xFF302522),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFE45B50),
                      size: 23,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada favorit',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF302522),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk, tambahkan karakter ke favorit '
              'dengan menekan ikon hati ♡',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Color(0xFF6B5B4E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteList(CharacterProvider provider) {
    return RefreshIndicator(
      color: const Color(0xFFA3C86D),
      onRefresh: provider.loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: provider.favorites.length,
        itemBuilder: (context, index) {
          final character = provider.favorites[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CharacterCard(
              character: character,
              isFavorite: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      character: character,
                    ),
                  ),
                );
              },
              onFavoriteTap: () async {
                try {
                  // Menghapus favorite dari Supabase dan daftar lokal.
                  await provider.toggleFavorite(character.id);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
