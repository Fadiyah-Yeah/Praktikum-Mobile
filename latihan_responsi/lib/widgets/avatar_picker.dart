
import 'package:flutter/material.dart';

import '../style/app_assets.dart';

class AvatarPicker extends StatelessWidget {
  final String? selectedAvatar;
  final ValueChanged<String> onSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatar,
    required this.onSelected,
  });

  // Daftar avatar yang dapat dipilih pengguna.
  static const List<String> avatars = [
    AppAssets.rick,
    AppAssets.morty,
    AppAssets.summer,
    AppAssets.beth,
    AppAssets.pickleRick,
    AppAssets.blueAlien,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: avatars.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = selectedAvatar == avatar;

        return GestureDetector(
          onTap: () => onSelected(avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE5EFC4)
                  : const Color(0xFFFCEED6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF7DA04E)
                    : const Color(0xFFDCC6A9),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Image.asset(
              avatar,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        );
      },
    );
  }
}
