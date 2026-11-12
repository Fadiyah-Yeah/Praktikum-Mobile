import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.favorite_border, 'Favorite'),
      (Icons.live_tv_outlined, 'Episode'),
    ];
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.mist,
      destinations: items
          .map((item) => NavigationDestination(
                icon: Icon(item.$1),
                label: item.$2,
              ))
          .toList(),
    );
  }
}
