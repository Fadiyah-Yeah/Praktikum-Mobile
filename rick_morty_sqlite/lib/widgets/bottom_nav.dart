import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: onTap,
    backgroundColor: AppColors.white,
    indicatorColor: AppColors.mist,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favorite'),
      NavigationDestination(icon: Icon(Icons.live_tv_outlined), label: 'Episode'),
    ],
  );
}
