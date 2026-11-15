import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> _login() async {
    try {
      await context.read<AuthProvider>().login(email: email.text, password: password.text);
      final auth = context.read<AuthProvider>();
      await context.read<ExplorerProvider>().loadFavorites(auth);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Consumer<AuthProvider>(builder: (context, auth, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.travel_explore, color: AppColors.sage, size: 30),
            ),
            const SizedBox(height: 28),
            Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            const Text('Sign in and continue exploring.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 28),
            AppField(controller: email, label: 'Email', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            AppField(controller: password, label: 'Password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 22),
            AppButton(label: 'Login', onPressed: _login, loading: auth.isLoading),
            const SizedBox(height: 12),
            Center(child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Belum punya akun? Daftar'),
            )),
          ],
        )),
      ),
    ))),
  );
}
