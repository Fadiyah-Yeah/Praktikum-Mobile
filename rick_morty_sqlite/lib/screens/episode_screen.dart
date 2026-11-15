import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/explorer_provider.dart';
import '../widgets/app_field.dart';
import '../widgets/bottom_nav.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().loadEpisodes(refresh: true);
    });
  }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  void _tab(int index) {
    if (index == 2) return;
    final page = index == 0 ? const HomeScreen() : const FavoriteScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Consumer<ExplorerProvider>(
    builder: (context, data, _) {
      final list = data.episodes.where((e) =>
        e.name.toLowerCase().contains(query.toLowerCase()) ||
        e.code.toLowerCase().contains(query.toLowerCase())).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Episode'), centerTitle: true),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppField(
              controller: search, label: 'Cari episode...', icon: Icons.search,
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: data.loadingEpisodes && data.episodes.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
                : list.isEmpty
                    ? const Center(child: Text('Episode tidak ditemukan.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length + (data.hasMoreEpisodes ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == list.length) {
                            return TextButton(
                              onPressed: data.loadingEpisodes ? null : () => data.loadEpisodes(),
                              child: const Text('Muat episode lainnya'),
                            );
                          }
                          final e = list[i];
                          return Card(
                            color: AppColors.white, elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: AppColors.sand),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.live_tv_outlined, color: AppColors.sage),
                              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${e.code} • ${e.airDate}'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.ivory,
                                  title: Text(e.name),
                                  content: Text('Kode: ${e.code}\nTanggal tayang: ${e.airDate}\nJumlah karakter: ${e.characters.length}'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ]),
        bottomNavigationBar: BottomNav(index: 2, onTap: _tab),
      );
    },
  );
}
