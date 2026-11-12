import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      await context.read<AuthProvider>().register(
        username.text, email.text, password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Silakan login jika diminta verifikasi email.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('A few details and you are ready to go.'),
                  const SizedBox(height: 28),
                  AppField(controller: username, label: 'Username', icon: Icons.person_outline),
                  const SizedBox(height: 14),
                  AppField(controller: email, label: 'Email', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  AppField(controller: password, label: 'Password (min. 6 characters)', icon: Icons.lock_outline, obscure: true),
                  const SizedBox(height: 22),
                  AppButton(label: 'Create account', onPressed: _register, loading: auth.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
