import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/character_tile.dart';
import '../widgets/app_field.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import 'episode_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().loadCharacters(refresh: true);
      context.read<ExplorerProvider>().loadFavorites();
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _tab(int index) {
    final page = [const HomeScreen(), const FavoriteScreen(), const EpisodeScreen()][index];
    if (index == 0) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExplorerProvider, AuthProvider>(
      builder: (context, data, auth, _) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ${auth.username.isEmpty ? 'Explorer' : auth.username}'),
              const Text('Explore the Rick & Morty universe', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: AppField(
                controller: search,
                label: 'Search characters',
                icon: Icons.search,
                onChanged: data.search,
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'Alive', 'Dead', 'Unknown'].map((status) {
                  final selected = data.selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) => data.filterStatus(status),
                      selectedColor: AppColors.sage,
                      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink),
                      backgroundColor: AppColors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: data.isLoadingCharacters && data.characters.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: .88,
                      ),
                      itemCount: data.characters.length + (data.hasMoreCharacters ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == data.characters.length) {
                          return Center(
                            child: TextButton(
                              onPressed: data.isLoadingCharacters ? null : () => data.loadCharacters(),
                              child: const Text('Load more'),
                            ),
                          );
                        }
                        final character = data.characters[index];
                        return CharacterTile(
                          character: character,
                          favorite: data.isFavorite(character.id),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(character: character))),
                          onFavorite: () async {
                            try {
                              await data.toggleFavorite(character);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNav(index: 0, onTap: _tab),
      ),
    );
  }
}
