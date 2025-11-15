import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pilih warna text kuat manual jika light
    Color getTitleColor() =>
        isDark ? Colors.white.withOpacity(0.96) : Colors.deepPurple[700]!;
    Color getBodyColor() =>
        isDark ? Colors.white70 : Colors.grey[900]!;
    Color getHighlightColor() =>
        isDark ? Colors.indigoAccent[100]! : Colors.indigo[700]!;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF232946), const Color(0xFF121629), Colors.black]
                : [const Color(0xFF6E9FFF), const Color(0xFFD3C2E7), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Card Container (tanpa icon di atas card)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 32),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.09) : Colors.white.withOpacity(0.18),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.blueGrey.withOpacity(0.13) : Colors.blueGrey.withOpacity(0.08),
                              offset: const Offset(0, 10), blurRadius: 38,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo/ikon utama
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: isDark ?
                                Colors.white.withOpacity(0.10) :
                                Colors.deepPurple[100]!.withOpacity(0.17),
                              child: Icon(
                                Icons.school_rounded,
                                size: 63,
                                color: getHighlightColor(),
                              ),
                            ),
                            const SizedBox(height: 23),
                            Text(
                              'Akademik Digital\nBrawijaya',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: getTitleColor(),
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(height: 13),
                            Text(
                              "Sistem manajemen data sekolah & kampus modern.\nCek jadwal, nilai, & pengumuman hanya di sini.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: getBodyColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 23),
                            // Glass highlight
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 330),
                              curve: Curves.ease,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.11)
                                          : Colors.white.withOpacity(0.20),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                    child: Center(
                                      child: Text(
                                        "Simple  •  Aman  •  Fast",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: getHighlightColor(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 27),
                            // Login Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: isDark ? 225 : 220,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: isDark ? Colors.blue[800] : Colors.deepPurple[400],
                                  foregroundColor: Colors.white,
                                  elevation: 9,
                                ),
                                icon: const Icon(Icons.login_rounded),
                                label: const Text(
                                  'Masuk ke Sistem',
                                  style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: .2),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.39)
                              : Colors.blueGrey.withOpacity(0.69),
                          fontSize: 13,
                        ),
                        child: const Text("© 2025 Brawijaya Akademik App"),
                      ),
                    ],
                  ),
                ),
              ),
              // Tombol theme switch
              Positioned(
                top: 19,
                right: 15,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.deepPurple.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    tooltip: isDark ? "Mode terang" : "Mode gelap",
                    icon: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      color: isDark
                          ? Colors.amberAccent[200]
                          : Colors.deepPurple.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
