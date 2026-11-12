
import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

class RickMortyApp extends StatelessWidget {
  const RickMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick & Morty Explorer',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.ivory,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sage,
          primary: AppColors.sage,
          secondary: AppColors.moss,
          surface: AppColors.ivory,
          onSurface: AppColors.ink,
        ),

        // Menggunakan font dan TextTheme bawaan Flutter.
        fontFamily: 'Roboto',
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.ivory,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.sand,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.sand,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.sage,
              width: 1.5,
            ),
          ),
        ),
      ),

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
