import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final confirm = TextEditingController();

  @override
  void dispose() {
    username.dispose(); email.dispose(); password.dispose(); confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (username.text.trim().length < 2 || !email.text.contains('@') ||
        password.text.length < 6 || password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periksa kembali data pendaftaran.')),
      );
      return;
    }
    try {
      await context.read<AuthProvider>().register(
        username: username.text, email: email.text, password: password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Consumer<AuthProvider>(builder: (context, auth, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            const Text('Create your local explorer account.', style: TextStyle(color: Color(0xFF777B75))),
            const SizedBox(height: 26),
            AppField(controller: username, label: 'Username', icon: Icons.person_outline),
            const SizedBox(height: 13),
            AppField(controller: email, label: 'Email', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 13),
            AppField(controller: password, label: 'Password (min. 6 characters)', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 13),
            AppField(controller: confirm, label: 'Confirm password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 22),
            AppButton(label: 'Create account', onPressed: _register, loading: auth.isLoading),
          ],
        )),
      ),
    ))),
  );
}
