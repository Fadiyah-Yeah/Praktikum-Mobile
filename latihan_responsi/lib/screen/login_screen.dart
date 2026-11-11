import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../style/app_assets.dart';
import '../style/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Mengelola validasi form login
  final _formKey = GlobalKey<FormState>();

  // Menyimpan input email dan password
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  // Mengatur visibilitas password dan loading
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Memproses login menggunakan Supabase Authentication
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    // Memvalidasi seluruh input sebelum login
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mengirim email dan password ke Supabase
      await SupabaseService.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Menampilkan pesan ketika login berhasil
      _showMessage('Login berhasil! Selamat datang.');

      // Mengarahkan pengguna ke Home dan menghapus riwayat navigasi
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on AuthException catch (e) {
      if (!mounted) return;

      // Menyesuaikan pesan berdasarkan jenis kesalahan autentikasi
      String message;

      switch (e.code) {
        case 'invalid_credentials':
          message = 'Email atau password yang kamu masukkan salah.';
          break;

        case 'email_not_confirmed':
          message = 'Silakan verifikasi email terlebih dahulu.';
          break;

        case 'user_not_found':
          message = 'Akun dengan email tersebut tidak ditemukan.';
          break;

        default:
          message = e.message;
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      // Menangani kesalahan koneksi atau kesalahan lainnya
      _showMessage(
        'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
        isError: true,
      );
    } finally {
      // Menghentikan loading setelah proses login selesai
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Menampilkan snackbar untuk informasi keberhasilan atau kesalahan
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

  // Mengatur tampilan input email dan password
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.textSecondary),

      // Icon di bagian kiri input
      prefixIcon: Icon(icon, size: 20, color: AppColors.textPrimary),

      // Icon tambahan di bagian kanan input
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: AppColors.surface,
      isDense: true,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      // Border default input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      // Border ketika input tidak aktif
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),

      // Border ketika input sedang digunakan
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),

      // Border ketika input mengalami kesalahan
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

  // Menampilkan background landscape pada bagian atas halaman
  Widget _buildLandscape(double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipPath(
        clipper: _LandscapeClipper(),
        child: Image.asset(
          AppAssets.splashBackground,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.15),
          filterQuality: FilterQuality.none,

          // Menampilkan warna fallback jika asset tidak ditemukan
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary,
              alignment: Alignment.center,
              child: Text(
                'Background tidak ditemukan',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
    );
  }

  // Menampilkan karakter Rick dan Morty
  Widget _buildCharacters(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          AppAssets.rick,
          width: width * 0.30,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),

        SizedBox(width: width * 0.01),

        Image.asset(
          AppAssets.morty,
          width: width * 0.27,
          height: height * 0.92,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Mengatur tinggi background dan karakter berdasarkan ukuran layar
    final landscapeHeight = screenHeight * 0.29;
    final characterHeight = screenHeight * 0.14;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Menempatkan landscape di bagian atas layar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildLandscape(landscapeHeight),
              ),

              // Mengatur konten utama agar bisa di-scroll pada layar kecil
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.065,
                      ),

                      child: Column(
                        children: [
                          // Memberikan ruang untuk background landscape
                          SizedBox(height: landscapeHeight - 5),

                          // Menampilkan karakter di tengah halaman
                          _buildCharacters(screenWidth, characterHeight),

                          const SizedBox(height: 5),

                          // Judul halaman login
                          Text(
                            'Login',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                          ),

                          const SizedBox(height: 2),

                          // Subtitle halaman login
                          Text(
                            'Masuk ke akunmu',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),

                          SizedBox(height: screenHeight * 0.035),

                          // Form untuk memasukkan email dan password
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Input email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],

                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textPrimary),

                                  decoration: _inputDecoration(
                                    hint: 'Email',
                                    icon: Icons.mail_outline,
                                  ),

                                  // Memvalidasi format email
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email wajib diisi';
                                    }

                                    final emailRegex = RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+$',
                                    );

                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Format email tidak valid';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Input password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],

                                  // Menjalankan login ketika tombol enter ditekan
                                  onFieldSubmitted: (_) {
                                    if (!_isLoading) {
                                      _login();
                                    }
                                  },

                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textPrimary),

                                  decoration: _inputDecoration(
                                    hint: 'Password',
                                    icon: Icons.lock_outline,

                                    // Tombol untuk melihat atau menyembunyikan password
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },

                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),

                                  // Memastikan password tidak kosong
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password wajib diisi';
                                    }

                                    return null;
                                  },
                                ),

                                SizedBox(height: screenHeight * 0.025),

                                // Tombol untuk menjalankan proses login
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,

                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
                                      foregroundColor: AppColors.white,
                                      disabledBackgroundColor:
                                          AppColors.primary,
                                      elevation: 0,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    // Menampilkan indikator ketika login diproses
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 21,
                                            height: 21,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : Text(
                                            'Login',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Navigasi menuju halaman register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textPrimary),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },

                                child: Text(
                                  'Daftar',
                                  style: Theme.of(context).textTheme.bodySmall
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Membersihkan controller ketika halaman ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}

// Membuat bagian bawah background landscape berbentuk lengkungan
class _LandscapeClipper extends CustomClipper<Path> {
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
