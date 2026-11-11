
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'style/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.supabaseUrl.isEmpty ||
      AppConfig.supabaseKey.isEmpty) {
    throw Exception(
      'Supabase URL dan Publishable Key belum dikonfigurasi.',
    );
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseKey,
  );

  runApp(
    const RickMortyApp(),
  );
}
