
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../providers/character_provider.dart';
import '../widgets/bottom_navbar.dart';

class DetailScreen extends StatefulWidget {
  final Character character;

  const DetailScreen({
    super.key,
    required this.character,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadCharacterDetail(
        widget.character.id,
      );
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFFA3C86D);
      case 'dead':
        return const Color(0xFFE88C6B);
      default:
        return const Color(0xFFB5B5B5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        final character =
            provider.selectedCharacter?.id == widget.character.id
                ? provider.selectedCharacter!
                : widget.character;

        final isFavorite = provider.isFavorite(character.id);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Landscape menjadi latar bagian atas detail.
                            SizedBox(
                              width: double.infinity,
                              height: 175,
                              child: Image.asset(
                                'asset/images/background.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              left: 4,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF302522),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF8E7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    try {
                                      await provider.toggleFavorite(
                                        character.id,
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? const Color(0xFFE45B50)
                                        : const Color(0xFF302522),
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -35,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 112,
                                  height: 112,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFDCC6A9),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      character.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 45),
                        Text(
                          character.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF302522),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(character.status)
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _statusColor(character.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                character.status,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF302522),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              _infoRow(
                                Icons.person_pin_outlined,
                                'Spesies',
                                character.species,
                              ),
                              _infoRow(
                                Icons.person_outline,
                                'Gender',
                                character.gender,
                              ),
                              _infoRow(
                                Icons.public,
                                'Origin',
                                character.originName,
                              ),
                              _infoRow(
                                Icons.location_on_outlined,
                                'Location',
                                character.locationName,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                BottomNavbar(
                  currentIndex: -1,
                  onTap: (index) {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDCC6A9),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF302522),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF302522),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Color(0xFF302522),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
