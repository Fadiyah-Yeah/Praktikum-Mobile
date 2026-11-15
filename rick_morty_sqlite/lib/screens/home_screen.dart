import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/app_field.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/character_card.dart';
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
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().loadCharacters(refresh: true);
      context.read<ExplorerProvider>().loadFavorites(context.read<AuthProvider>());
    });
  }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  void _tab(int index) {
    if (index == 0) return;
    final page = index == 1 ? const FavoriteScreen() : const EpisodeScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Consumer2<ExplorerProvider, AuthProvider>(
    builder: (context, data, auth, _) => Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hi, ${auth.currentUser?.username ?? 'Explorer'}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const Text('Explore the Rick & Morty universe', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
          child: AppField(
            controller: search, label: 'Cari karakter...', icon: Icons.search,
            onChanged: data.searchCharacters,
          ),
        ),
        StatusFilter(selected: data.status, onSelected: data.filterStatus),
        const SizedBox(height: 8),
        Expanded(
          child: data.loadingCharacters && data.characters.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
              : data.characters.isEmpty
                  ? Center(child: Text(data.error ?? 'Karakter tidak ditemukan.'))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 180 &&
                            data.hasMoreCharacters && !data.loadingCharacters) {
                          data.loadCharacters();
                        }
                        return false;
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                          childAspectRatio: .88,
                        ),
                        itemCount: data.characters.length,
                        itemBuilder: (context, i) {
                          final c = data.characters[i];
                          return CharacterCard(
                            character: c, favorite: data.isFavorite(c.id),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(character: c))),
                            onFavorite: () async {
                              try { await data.toggleFavorite(c, auth); }
                              catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            },
                          );
                        },
                      ),
                    ),
        ),
      ]),
      bottomNavigationBar: BottomNav(index: 0, onTap: _tab),
    ),
  );
}
