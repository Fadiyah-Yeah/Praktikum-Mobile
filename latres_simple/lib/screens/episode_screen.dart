import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/explorer_provider.dart';
import '../widgets/app_field.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final search = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ExplorerProvider>().loadEpisodes(refresh: true));
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _tab(int index) {
    if (index == 2) return;
    final page = index == 0 ? const HomeScreen() : const FavoriteScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, data, _) {
        final episodes = data.episodes.where((e) =>
          e.name.toLowerCase().contains(query.toLowerCase()) ||
          e.code.toLowerCase().contains(query.toLowerCase())).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Episodes'), centerTitle: true),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: AppField(
                  controller: search,
                  label: 'Search episodes',
                  icon: Icons.search,
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
              Expanded(
                child: data.isLoadingEpisodes && data.episodes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: episodes.length + (data.episodes.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == episodes.length) {
                            return TextButton(
                              onPressed: () => data.loadEpisodes(),
                              child: const Text('Load more episodes'),
                            );
                          }
                          final episode = episodes[index];
                          return Card(
                            color: AppColors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.live_tv_outlined, color: AppColors.sage),
                              title: Text(episode.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${episode.code} • ${episode.airDate}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNav(index: 2, onTap: _tab),
        );
      },
    );
  }
}
