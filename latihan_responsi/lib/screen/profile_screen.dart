
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/pixel_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController =
      TextEditingController();

  bool _showAvatarPicker = false;
  bool _isInitialized = false;
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();

    // Mengambil data profil dari Supabase.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AuthProvider>();
      await provider.loadProfile();

      if (!mounted) return;

      _usernameController.text = provider.user?.username ?? '';
      _selectedAvatar = provider.user?.avatar;

      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();

    if (username.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username minimal 2 karakter.'),
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().updateProfile(
        username: username,
        avatar: _selectedAvatar,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Color(0xFF7DA04E),
        ),
      );

      setState(() {
        _showAvatarPicker = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF8E7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Ganti Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password baru',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Password tidak sama.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    try {
                      await context.read<AuthProvider>().updatePassword(
                        passwordController.text,
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password berhasil diperbarui.'),
                          backgroundColor: Color(0xFF7DA04E),
                        ),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3C86D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _logout() async {
    try {
      await context.read<AuthProvider>().logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        if (!_isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8E7),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFA3C86D),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: SafeArea(
            child: Column(
              children: [
                // Header profil.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Profil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF302522),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        // Avatar utama dengan tombol edit.
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EFC4),
                                borderRadius: BorderRadius.circular(23),
                                border: Border.all(
                                  color: const Color(0xFFDCC6A9),
                                ),
                              ),
                              child: _selectedAvatar != null
                                  ? Image.asset(
                                      _selectedAvatar!,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 60,
                                    ),
                            ),
                            Positioned(
                              right: -7,
                              bottom: -5,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAvatarPicker =
                                        !_showAvatarPicker;
                                  });
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF7DA04E),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 17,
                                    color: Color(0xFF302522),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          _usernameController.text,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF302522),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          SupabaseService.currentUser?.email ?? '',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Color(0xFF6B5B4E),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          color: Color(0xFFDCC6A9),
                        ),

                        // Pilihan avatar hanya muncul ketika tombol pensil ditekan.
                        if (_showAvatarPicker) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pilih Avatar',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF302522),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AvatarPicker(
                            selectedAvatar: _selectedAvatar,
                            onSelected: (avatar) {
                              setState(() {
                                _selectedAvatar = avatar;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Informasi Akun',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF302522),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Username dapat diedit langsung.
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: const Color(0xFFFCEED6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCC6A9),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCC6A9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password diubah melalui dialog.
                        OutlinedButton.icon(
                          onPressed: _showPasswordDialog,
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Ganti Password'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B5B4E),
                            side: const BorderSide(
                              color: Color(0xFFDCC6A9),
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              48,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        PixelButton(
                          text: 'Simpan Perubahan',
                          isLoading: provider.isLoading,
                          onPressed: _saveProfile,
                        ),
                        const SizedBox(height: 12),

                        PixelButton(
                          text: 'Logout',
                          icon: Icons.logout,
                          backgroundColor: const Color(0xFFE88C6B),
                          onPressed: provider.isLoading ? null : _logout,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
