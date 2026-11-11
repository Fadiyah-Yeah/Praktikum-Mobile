
import 'package:flutter/material.dart';

import '../models/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const CharacterCard({
    super.key,
    required this.character,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  // Menentukan warna indikator berdasarkan status karakter.
  Color _getStatusColor() {
    switch (character.status.toLowerCase()) {
      case 'alive':
        return const Color(0xFF6DAA3D);
      case 'dead':
        return const Color(0xFFE5735B);
      default:
        return const Color(0xFF9B9B9B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF8E7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDCC6A9),
            ),
          ),
          child: Row(
            children: [
              // Gambar karakter dari Rick and Morty API.
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  character.image,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFFFCEED6),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF6B5B4E),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF302522),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          character.status,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Color(0xFF6B5B4E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoriteTap,
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? const Color(0xFFE45B50)
                      : const Color(0xFF302522),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
