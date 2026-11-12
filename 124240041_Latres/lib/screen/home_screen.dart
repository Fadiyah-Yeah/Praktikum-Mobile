
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/character_provider.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/character_card.dart';
import '../widgets/search_field.dart';
import '../widgets/status_filter.dart';

import 'detail_screen.dart';
import 'episode_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadCharacters(refresh: true);
      context.read<CharacterProvider>().loadFavorites();
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _openDetail(int index) {
    final character =
        context.read<CharacterProvider>().characters[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(character: character),
      ),
    );
  }

  void _navigateToTab(int index) {
    if (index == 0) return;

    final page = index == 1
        ? const FavoriteScreen()
        : const EpisodeScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CharacterProvider, AuthProvider>(
      builder: (context, characterProvider, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hai, ${user?.username ?? 'Pengguna'}!',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF302522),
                                  ),
                                ),
                                const Text(
                                  'Jelajahi karakter Rick & Morty',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    color: Color(0xFF6B5B4E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _openProfile,
                            child: CircleAvatar(
                              radius: 23,
                              backgroundColor: const Color(0xFFE5EFC4),
                              child: user?.avatar != null
                                  ? ClipOval(
                                      child: Image.asset(
                                        user!.avatar!,
                                        width: 43,
                                        height: 43,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Color(0xFF6B5B4E),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SearchField(
                        controller: _searchController,
                        hintText: 'Cari karakter...',
                        onChanged: (value) {
                          characterProvider.searchCharacters(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StatusFilter(
                          selectedStatus:
                              characterProvider.selectedStatus,
                          onSelected: (status) {
                            characterProvider.filterByStatus(status);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildCharacters(characterProvider),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavbar(
            currentIndex: 0,
            onTap: _navigateToTab,
          ),
        );
      },
    );
  }

  Widget _buildCharacters(CharacterProvider provider) {
    if (provider.isLoading && provider.characters.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFA3C86D),
        ),
      );
    }

    if (provider.characters.isEmpty) {
      return Center(
        child: Text(
          provider.errorMessage ?? 'Karakter tidak ditemukan.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFA3C86D),
      onRefresh: () => provider.loadCharacters(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: provider.characters.length +
            (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.characters.length) {
            return Center(
              child: TextButton(
                onPressed: provider.isLoadingMore
                    ? null
                    : () => provider.loadCharacters(),
                child: provider.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const Text('Muat lebih banyak'),
              ),
            );
          }

          final character = provider.characters[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: CharacterCard(
              character: character,
              isFavorite: provider.isFavorite(character.id),
              onTap: () => _openDetail(index),
              onFavoriteTap: () async {
                try {
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
