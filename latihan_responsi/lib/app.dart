
import 'package:flutter/material.dart';

import 'style/app_colors.dart';
import 'style/app_theme.dart';

class RickMortyApp extends StatelessWidget {
  const RickMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick & Morty Explorer',
      theme: AppTheme.lightTheme,
      home: const SetupPreviewScreen(),
    );
  }
}

class SetupPreviewScreen extends StatelessWidget {
  const SetupPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.public,
                    size: 75,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Rick & Morty',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Character Explorer',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                const CircularProgressIndicator(
                  color: AppColors.primaryDark,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Preparing your adventure...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
