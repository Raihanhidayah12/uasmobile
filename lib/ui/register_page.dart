import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../providers/auth_provider.dart';
import 'widgets/app_text_field.dart';
import 'widgets/app_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;

  final String _role = 'siswa_pending';

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(begin: const Offset(0, 0.11), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeOutQuart),
          );
          final fade = Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeIn));
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary ?? Colors.blue;

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
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.22),
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
                    color: isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.17),
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
                                Icons.person_add_alt_1_rounded,
                                size: 45,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Buat Akun Baru",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white.withOpacity(0.95)
                                    : Colors.indigo[700] ?? Colors.indigo,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _username,
                              label: 'Username',
                              keyboardType: TextInputType.text,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Username wajib diisi";
                                }
                                if (v.contains("@")) {
                                  return "Jangan pakai @, cukup username saja";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _pass,
                              label: 'Password',
                              obscure: true,
                              validator: (v) => Validators.password(v, min: 6),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _confirm,
                              label: 'Konfirmasi Password',
                              obscure: true,
                              validator: (v) => Validators.confirm(v, _pass.text),
                            ),
                            const SizedBox(height: 18),
                            if (auth.error != null)
                              Text(
                                auth.error!,
                                style: TextStyle(color: theme.colorScheme.error ?? Colors.red),
                              ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Daftar',
                              loading: _submitting,
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) return;
                                      setState(() => _submitting = true);

                                      final email = "${_username.text.trim()}@Brawijaya.com";
                                      final ok = await context.read<AuthProvider>().register(
                                            email,
                                            _pass.text,
                                            role: _role,
                                          );

                                      if (!mounted) return;
                                      setState(() => _submitting = false);

                                      if (ok) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Registrasi berhasil! Akun Anda menunggu verifikasi admin.'),
                                          ),
                                        );
                                        _navigateToLogin(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              auth.error ?? 'Gagal daftar, coba lagi',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Sudah punya akun? "),
                                TextButton(
                                  onPressed: () => _navigateToLogin(context),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
