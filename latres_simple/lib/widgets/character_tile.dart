import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/character.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const CharacterTile({
    super.key,
    required this.character,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  Color get statusColor {
    switch (character.status.toLowerCase()) {
      case 'alive': return AppColors.sage;
      case 'dead': return AppColors.danger;
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.sand.withOpacity(.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onFavorite,
                child: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? AppColors.danger : AppColors.ink,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    character.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 42),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              character.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: statusColor),
                const SizedBox(width: 6),
                Text(character.status, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
