
import 'package:flutter/material.dart';

import '../style/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore,
              size: 65,
              color: AppColors.primaryDark,
            ),

            const SizedBox(height: 16),

            Text(
              'Home Screen',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 8),

            const Text(
              'Selamat datang kembali!',
            ),
          ],
        ),
      ),
    );
  }
}
