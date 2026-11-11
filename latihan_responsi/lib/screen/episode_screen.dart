
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/episode.dart';
import '../providers/character_provider.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/search_field.dart';

import 'home_screen.dart';
import 'favorite_screen.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadEpisodes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (index == 2) return;

    final page = index == 0
        ? const HomeScreen()
        : const FavoriteScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showEpisodeDetail(Episode episode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          episode.name,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Kode Episode', episode.episode),
            _detailRow('Tanggal Tayang', episode.airDate),
            _detailRow(
              'Jumlah Karakter',
              '${episode.characterCount} karakter',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF7DA04E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: Color(0xFF9B8A7B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              color: Color(0xFF302522),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        final filteredEpisodes = provider.episodes.where((episode) {
          final query = _searchQuery.toLowerCase();

          return episode.name.toLowerCase().contains(query) ||
              episode.episode.toLowerCase().contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: SafeArea(
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Image.asset(
                        'asset/images/splash_bg.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    const SizedBox(
                      height: 55,
                      child: Center(
                        child: Text(
                          'Episode',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF302522),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Cari episode...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildEpisodeList(
                    provider,
                    filteredEpisodes,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavbar(
            currentIndex: 2,
            onTap: _navigateToTab,
          ),
        );
      },
    );
  }

  Widget _buildEpisodeList(
    CharacterProvider provider,
    List<Episode> episodes,
  ) {
    if (provider.isLoading && provider.episodes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFA3C86D),
        ),
      );
    }

    if (provider.errorMessage != null &&
        provider.episodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: provider.loadEpisodes,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (episodes.isEmpty) {
      return const Center(
        child: Text(
          'Episode tidak ditemukan.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => _showEpisodeDetail(episode),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCC6A9),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEED6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.live_tv_outlined,
                        color: Color(0xFF6B5B4E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF302522),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            episode.airDate,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: Color(0xFF6B5B4E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9B8A7B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
