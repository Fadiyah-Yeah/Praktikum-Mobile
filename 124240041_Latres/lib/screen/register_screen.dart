import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../../style/app_assets.dart';
import '../../style/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Mengelola validasi form
  final _formKey = GlobalKey<FormState>();

  // Menyimpan input pengguna
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Mengatur visibilitas password dan loading
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Memproses registrasi melalui Supabase
  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Membuat akun dan menyimpan nama sebagai metadata
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (!mounted) return;

      if (response.session != null) {
        _showMessage('Registrasi berhasil! Selamat datang, $name.');

        // Langsung menuju Home jika sesi tersedia
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        _showMessage(
          'Akun berhasil dibuat. Silakan verifikasi email terlebih dahulu.',
        );

        // Kembali ke Login jika verifikasi diperlukan
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user_already_exists':
          message = 'Email sudah terdaftar. Silakan login.';
          break;

        case 'weak_password':
          message = 'Password terlalu lemah.';
          break;

        default:
          message = e.message;
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Registrasi gagal. Periksa koneksi internetmu.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Menampilkan pesan keberhasilan atau kesalahan
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // Mengatur tampilan input form
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.textSecondary),

      prefixIcon: Icon(icon, size: 20, color: AppColors.textPrimary),

      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // Membuat input password dengan tombol visibilitas
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      textInputAction: textInputAction,

      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.textPrimary),

      decoration: _inputDecoration(
        hint: hint,
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),

      validator: validator,
    );
  }

  // Menampilkan background landscape
  Widget _buildLandscape(double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipPath(
        clipper: _RegisterLandscapeClipper(),
        child: Image.asset(
          AppAssets.splashBackground,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.15),
          filterQuality: FilterQuality.none,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: AppColors.primary);
          },
        ),
      ),
    );
  }

  // Menampilkan UFO sebagai dekorasi
  Widget _buildUfo(double width) {
    return Image.asset(
      AppAssets.ufo,
      width: width * 0.38,
      height: 85,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Membatasi lebar agar tetap nyaman di layar desktop
    final contentWidth = screenWidth > 430 ? 430.0 : screenWidth;

    final landscapeHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: Center(
                  child: SizedBox(
                    width: contentWidth,

                    child: Stack(
                      children: [
                        // Background landscape
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _buildLandscape(landscapeHeight),
                        ),

                        // UFO di atas judul
                        Positioned(
                          top: landscapeHeight * 0.43,
                          left: 0,
                          right: 0,
                          child: Center(child: _buildUfo(contentWidth)),
                        ),

                        // Konten registrasi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),

                          child: Column(
                            children: [
                              // Memberikan ruang untuk landscape dan UFO
                              SizedBox(height: landscapeHeight + 12),

                              // Judul registrasi
                              Text(
                                'Daftar',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Buat akun baru',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),

                              const SizedBox(height: 22),

                              // Form registrasi
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Input nama
                                    TextFormField(
                                      controller: _nameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.name],
                                      decoration: _inputDecoration(
                                        hint: 'Nama',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Nama wajib diisi';
                                        }

                                        if (value.trim().length < 2) {
                                          return 'Nama minimal 2 karakter';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // Input email
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      decoration: _inputDecoration(
                                        hint: 'Email',
                                        icon: Icons.mail_outline,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Email wajib diisi';
                                        }

                                        final emailRegex = RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+$',
                                        );

                                        if (!emailRegex.hasMatch(
                                          value.trim(),
                                        )) {
                                          return 'Format email tidak valid';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // Input password
                                    _buildPasswordField(
                                      controller: _passwordController,
                                      hint: 'Password',
                                      isVisible: _isPasswordVisible,
                                      onToggle: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password wajib diisi';
                                        }

                                        if (value.length < 6) {
                                          return 'Password minimal 6 karakter';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // Input konfirmasi password
                                    _buildPasswordField(
                                      controller: _confirmPasswordController,
                                      hint: 'Konfirmasi Password',
                                      isVisible: _isConfirmPasswordVisible,
                                      textInputAction: TextInputAction.done,
                                      onToggle: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Konfirmasi password wajib diisi';
                                        }

                                        if (value != _passwordController.text) {
                                          return 'Password tidak cocok';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Tombol daftar
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _register,

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryDark,
                                          foregroundColor: AppColors.white,
                                          disabledBackgroundColor:
                                              AppColors.primary,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),

                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 21,
                                                height: 21,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: AppColors.white,
                                                    ),
                                              )
                                            : Text(
                                                'Daftar',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Navigasi kembali ke Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun? ',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: AppColors.primaryDark,
                                    ),
                                    child: Text(
                                      'Login',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Membersihkan controller
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }
}

// Membuat lengkungan pada bagian bawah background
class _RegisterLandscapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 25)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 18,
        size.width,
        size.height - 25,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
