import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/character.dart';
import '../providers/explorer_provider.dart';

class DetailScreen extends StatelessWidget {
  final Character character;
  const DetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, data, _) {
        final favorite = data.isFavorite(character.id);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Character'),
            actions: [
              IconButton(
                onPressed: () async {
                  try {
                    await data.toggleFavorite(character);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? AppColors.danger : AppColors.ink),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(character.image, width: 170, height: 170, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 18),
              Text(character.name, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  avatar: CircleAvatar(backgroundColor: character.status.toLowerCase() == 'alive' ? AppColors.sage : AppColors.danger, radius: 5),
                  label: Text(character.status),
                  backgroundColor: AppColors.mist,
                ),
              ),
              const SizedBox(height: 18),
              _info('Species', character.species),
              _info('Gender', character.gender),
              _info('Origin', character.origin),
              _info('Last known location', character.location),
              _info('Episodes', '${character.episodes.length}'),
            ],
          ),
        );
      },
    );
  }

  Widget _info(String label, String value) => Card(
    color: AppColors.white,
    child: ListTile(title: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600))),
  );
}
