import 'package:flutter/material.dart';

import 'style/app_theme.dart';

import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'screen/register_screen.dart';

import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/character_provider.dart';

class RickMortyApp extends StatelessWidget {
  const RickMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Rick & Morty Explorer',

        theme: AppTheme.lightTheme,

        home: const SplashScreen(),

        routes: {
          '/login': (context) => const LoginScreen(),
          '/splash': (context) => const SplashScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
