import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'widgets/app_text_field.dart';
import 'widgets/app_button.dart';

// Import dashboard sesuai role
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
                    theme.colorScheme.primaryContainer.withOpacity(0.95)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 480,
                    ),
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
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.lock_outline,
                                size: 50,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Sistem Informasi Akademik",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              controller: _email,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _pass,
                              label: 'Password',
                              obscure: true,
                              validator: (v) => Validators.password(v, min: 6),
                            ),
                            const SizedBox(height: 16),
                            if (auth.error != null)
                              Text(
                                auth.error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Masuk',
                              loading: _submitting,
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      setState(() => _submitting = true);

                                      final ok = await context
                                          .read<AuthProvider>()
                                          .login(
                                              _email.text.trim(), _pass.text);

                                      setState(() => _submitting = false);

                                      if (!mounted) return;

                                      if (ok) {
                                        final user =
                                            context.read<AuthProvider>().current!;

                                        if (user.role == 'siswa_pending') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Akun Anda menunggu verifikasi admin',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        Widget page;
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
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Role tidak dikenal'),
                                              ),
                                            );
                                            return;
                                        }

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => page),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              auth.error ?? 'Login gagal',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage()),
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
