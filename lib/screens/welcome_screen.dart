import 'package:flutter/material.dart';

import '../auth/auth_repository.dart';
import '../auth/auth_service.dart';
import '../auth/models/user.dart';
import 'package:krishi_sakhi/screens/Signin_Page/signinpage.dart'; // for HomeDashboard reference

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final AuthRepository _repo;
  Future<User?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _repo = AuthRepository(service: AuthService());
    _profileFuture = _repo.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FutureBuilder<User?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Could not load profile',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  final user = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Welcome to Krishi Sakhi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        child:
                            user?.imageUrl != null
                                ? null
                                : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                        backgroundImage:
                            user?.imageUrl != null
                                ? NetworkImage(user!.imageUrl!)
                                : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Farmer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (user?.farm != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user!.farm!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (_, __, ___) => const HomeDashboard(),
                              transitionsBuilder:
                                  (_, a, __, child) =>
                                      FadeTransition(opacity: a, child: child),
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
