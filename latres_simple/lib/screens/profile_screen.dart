import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.loadProfile();
      if (!mounted) return;
      username.text = auth.username;
    });
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (username.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username minimal 2 karakter.')));
      return;
    }
    try {
      await context.read<AuthProvider>().updateUsername(username.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username berhasil diperbarui.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _changePassword() async {
    if (password.text.length < 6 || password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pastikan password minimal 6 karakter dan konfirmasi sesuai.')));
      return;
    }
    try {
      await context.read<AuthProvider>().updatePassword(password.text);
      password.clear();
      confirm.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diperbarui.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.mist,
              child: Icon(Icons.settings_outlined, size: 30, color: AppColors.sage),
            ),
            const SizedBox(height: 12),
            Text(auth.username, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 26),
            const Text('Account details', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppField(controller: username, label: 'Username', icon: Icons.person_outline),
            const SizedBox(height: 10),
            AppButton(label: 'Save username', onPressed: _saveUsername, loading: auth.isLoading),
            const SizedBox(height: 28),
            const Text('Change password', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppField(controller: confirm, label: 'Confirm new password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 10),
            AppButton(label: 'Update password', onPressed: _changePassword, secondary: true, loading: auth.isLoading),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: auth.isLoading ? null : _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}
