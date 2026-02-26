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
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20), // Darker Forest Green
              Color(0xFF2E7D32), // Medium Green
              Color(0xFF66BB6A), // Lighter soft green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: FutureBuilder<User?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  // 1. Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // 2. Error State
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white70,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Could not load profile',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Success State
                  final user = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Welcome Text
                      const Text(
                        'Welcome to\nKrishi Sakhi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Profile Avatar with premium border & shadow
                      Container(
                        padding: const EdgeInsets.all(4), // Border width
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white24,
                          backgroundImage:
                              user?.imageUrl != null
                                  ? NetworkImage(user!.imageUrl!)
                                  : null,
                          child:
                              user?.imageUrl != null
                                  ? null
                                  : const Icon(
                                    Icons.person_rounded,
                                    size: 65,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // User Name
                      Text(
                        user?.name ?? 'Farmer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Farm Name (if available)
                      if (user?.farm != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user!.farm!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 56),

                      // Continue Button (High Contrast)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(
                              0xFF1B5E20,
                            ), // Dark green text
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, __, ___) => const HomeDashboard(),
                                transitionsBuilder:
                                    (_, a, __, child) => FadeTransition(
                                      opacity: a,
                                      child: child,
                                    ),
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 22,
                          ),
                          label: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Bottom padding
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
