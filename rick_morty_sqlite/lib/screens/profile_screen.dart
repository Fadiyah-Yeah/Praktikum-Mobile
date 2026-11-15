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
    username.text = context.read<AuthProvider>().currentUser?.username ?? '';
  }

  @override
  void dispose() {
    username.dispose(); password.dispose(); confirm.dispose(); super.dispose();
  }

  Future<void> _saveName() async {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter dan konfirmasi harus sama.')));
      return;
    }
    try {
      await context.read<AuthProvider>().updatePassword(password.text);
      password.clear(); confirm.clear();
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
  Widget build(BuildContext context) => Consumer<AuthProvider>(
    builder: (context, auth, _) => Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          width: 62, height: 62, alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.settings_outlined, size: 31, color: AppColors.sage),
        ),
        const SizedBox(height: 12),
        Text(auth.currentUser?.username ?? '', textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        Text(auth.currentUser?.email ?? '', textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 28),
        const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        AppField(controller: username, label: 'Username', icon: Icons.person_outline),
        const SizedBox(height: 10),
        AppButton(label: 'Save username', onPressed: _saveName, loading: auth.isLoading),
        const SizedBox(height: 28),
        const Text('Change password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: password, obscureText: obscure,
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
        AppButton(label: 'Update password', onPressed: _changePassword, loading: auth.isLoading, outlined: true),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: auth.isLoading ? null : _logout,
          icon: const Icon(Icons.logout), label: const Text('Logout'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
        ),
      ]),
    ),
  );
}
