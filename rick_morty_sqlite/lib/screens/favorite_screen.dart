import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/bottom_nav.dart';
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
      context.read<ExplorerProvider>().loadFavorites(context.read<AuthProvider>());
    });
  }

  void _tab(int index) {
    if (index == 1) return;
    final page = index == 0 ? const HomeScreen() : const EpisodeScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Consumer2<ExplorerProvider, AuthProvider>(
    builder: (context, data, auth, _) => Scaffold(
      appBar: AppBar(title: const Text('Favorite'), centerTitle: true),
      body: data.loadingFavorites
          ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
          : data.favorites.isEmpty
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.favorite_border, size: 58, color: AppColors.moss),
                  SizedBox(height: 14),
                  Text('Belum ada favorite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('Tambahkan karakter dari halaman Home.', style: TextStyle(color: AppColors.muted)),
                ]))
              : GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .88,
                  ),
                  itemCount: data.favorites.length,
                  itemBuilder: (context, i) {
                    final c = data.favorites[i];
                    return CharacterCard(
                      character: c, favorite: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(character: c))),
                      onFavorite: () => data.toggleFavorite(c, auth),
                    );
                  },
                ),
      bottomNavigationBar: BottomNav(index: 1, onTap: _tab),
    ),
  );
}
