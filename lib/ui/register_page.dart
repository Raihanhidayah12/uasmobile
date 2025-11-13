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
  final _username = TextEditingController(); // ✅ hanya username, bukan email penuh
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;

  /// Default role → akun baru otomatis jadi siswa_pending
  final String _role = 'siswa_pending';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [
                    theme.colorScheme.primary.withOpacity(0.9),
                    theme.colorScheme.primaryContainer.withOpacity(0.95),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Buat Akun Baru",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 24),

                            /// ✅ Input hanya username
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
                              validator: (v) =>
                                  Validators.confirm(v, _pass.text),
                            ),
                            const SizedBox(height: 20),

                            if (auth.error != null)
                              Text(
                                auth.error!,
                                style: TextStyle(color: theme.colorScheme.error),
                              ),

                            const SizedBox(height: 20),
                            AppButton(
                              text: 'Daftar',
                              loading: _submitting,
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      setState(() => _submitting = true);

                                      /// 🔹 buat email otomatis
                                      final email =
                                          "${_username.text.trim()}@sekolah.com";

                                      final ok = await context
                                          .read<AuthProvider>()
                                          .register(
                                            email,
                                            _pass.text,
                                            role: _role,
                                          );

                                      if (!mounted) return;
                                      setState(() => _submitting = false);

                                      if (ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Registrasi berhasil! Akun Anda menunggu verifikasi admin.',
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
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
