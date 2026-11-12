import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/explorer_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/character_tile.dart';
import 'home_screen.dart';
import 'episode_screen.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ExplorerProvider>().loadFavorites());
  }

  void _tab(int index) {
    if (index == 1) return;
    final page = index == 0 ? const HomeScreen() : const EpisodeScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, data, _) => Scaffold(
        appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
        body: data.isLoadingFavorites
            ? const Center(child: CircularProgressIndicator())
            : data.favorites.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 58, color: AppColors.moss),
                        SizedBox(height: 14),
                        Text('No favorites yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Save characters you love from Home.', style: TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .88,
                    ),
                    itemCount: data.favorites.length,
                    itemBuilder: (context, index) {
                      final character = data.favorites[index];
                      return CharacterTile(
                        character: character,
                        favorite: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(character: character))),
                        onFavorite: () => data.toggleFavorite(character),
                      );
                    },
                  ),
        bottomNavigationBar: BottomNav(index: 1, onTap: _tab),
      ),
    );
  }
}
