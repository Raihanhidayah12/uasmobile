import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'widgets/app_text_field.dart';
import 'widgets/app_button.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/guru_dashboard.dart';
import 'dashboards/siswa_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _submitting = false;
  bool _showPassword = false;

  void _navigateWithFadeSlide(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutExpo));
          final fade = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(slide),
            child: FadeTransition(
              opacity: animation.drive(fade),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // [web:23]
        backgroundColor: Colors.red[600],
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData? theme = Theme.of(context);
    final bool isDark = theme?.brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final primaryColor = theme?.colorScheme.primary ?? Colors.blue;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[950] ?? Colors.black, Colors.indigo[900] ?? Colors.black]
                : [const Color(0xFF90CAF9), const Color(0xFFE3EBF7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutQuad,
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.blueGrey.withOpacity(0.18)
                          : Colors.blue.withOpacity(0.11),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.white.withOpacity(0.17),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 43,
                              backgroundColor: primaryColor.withOpacity(0.11),
                              child: Icon(
                                Icons.lock_outline_rounded,
                                size: 45,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Sistem Informasi Akademik",
                              style: theme?.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white.withOpacity(0.95)
                                    : Colors.indigo[700] ?? Colors.indigo,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _email,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              controller: _pass,
                              obscureText: !_showPassword,
                              validator: (v) => Validators.password(v, min: 6),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.key),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 11),

                            // Error card modern di bawah field (optional)
                            if (authProv.error != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProv.error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Masuk',
                              loading: _submitting,
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) return;
                                      setState(() => _submitting = true);
                                      final ok = await context
                                          .read<AuthProvider>()
                                          .login(_email.text.trim(), _pass.text);
                                      setState(() => _submitting = false);

                                      if (!mounted) return;
                                      if (ok) {
                                        final user =
                                            context.read<AuthProvider>().current;
                                        if (user == null) {
                                          _showErrorSnack(
                                            context,
                                            'Terjadi error: data user null',
                                          );
                                          return;
                                        }
                                        if (user.role == 'siswa_pending') {
                                          _showErrorSnack(
                                            context,
                                            'Akun Anda menunggu verifikasi admin',
                                          );
                                          return;
                                        }
                                        Widget? page;
                                        switch (user.role) {
                                          case 'admin':
                                            page = const DashboardAdmin();
                                            break;
                                          case 'guru':
                                            page = const DashboardGuru();
                                            break;
                                          case 'siswa':
                                            page = const DashboardSiswa();
                                            break;
                                          default:
                                            page = null;
                                        }
                                        if (page != null) {
                                          _navigateWithFadeSlide(context, page);
                                        } else {
                                          _showErrorSnack(
                                            context,
                                            'Role tidak dikenal',
                                          );
                                        }
                                      } else {
                                        _showErrorSnack(
                                          context,
                                          authProv.error ?? 'Login gagal. Coba lagi.',
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 13),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 450),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const RegisterPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    final slide = Tween<Offset>(
                                      begin: const Offset(0, 0.13),
                                      end: Offset.zero,
                                    ).chain(
                                      CurveTween(curve: Curves.easeOutBack),
                                    );
                                    final fade = Tween<double>(
                                      begin: 0,
                                      end: 1,
                                    ).chain(
                                      CurveTween(curve: Curves.easeIn),
                                    );
                                    return SlideTransition(
                                      position: animation.drive(slide),
                                      child: FadeTransition(
                                        opacity: animation.drive(fade),
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              child: const Text(
                                'Belum punya akun? Daftar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
