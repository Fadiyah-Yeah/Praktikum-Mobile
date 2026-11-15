import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/character.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';

class DetailScreen extends StatelessWidget {
  final Character character;
  const DetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) => Consumer2<ExplorerProvider, AuthProvider>(
    builder: (context, data, auth, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Detail karakter'),
        actions: [
          IconButton(
            onPressed: () async {
              try { await data.toggleFavorite(character, auth); }
              catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            icon: Icon(
              data.isFavorite(character.id) ? Icons.favorite : Icons.favorite_border,
              color: data.isFavorite(character.id) ? AppColors.danger : AppColors.ink,
            ),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(character.image, width: 160, height: 160, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, size: 100, color: AppColors.moss)),
        )),
        const SizedBox(height: 18),
        Text(character.name, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Center(child: Chip(backgroundColor: AppColors.mist, label: Text(character.status))),
        const SizedBox(height: 18),
        _info('Species', character.species),
        _info('Gender', character.gender),
        _info('Origin', character.origin),
        _info('Last known location', character.location),
        _info('Number of episodes', '${character.episodes.length}'),
      ]),
    ),
  );

  Widget _info(String label, String value) => Card(
    color: AppColors.white, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: AppColors.sand)),
    child: ListTile(
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
    ),
  );
}
