import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:krishi_sakhi/screens/create_account_screen.dart';
import 'package:krishi_sakhi/screens/signin_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  final _mobileFocusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  String _selectedCountryCode = '+91';
  bool _isPinVisible = false;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScale;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'country': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
    {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();

    for (final node in [_mobileFocusNode, _pinFocusNode]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    _mobileFocusNode.dispose();
    _pinFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_mobileController.text.isEmpty) {
      _showError('Please enter your mobile number');
      return;
    }
    if (_mobileController.text.length != 10) {
      _showError('Enter valid 10-digit number');
      return;
    }
    if (_pinController.text.isEmpty) {
      _showError('Please enter your PIN');
      return;
    }
    if (_pinController.text.length != 4) {
      _showError('PIN must be 4 digits');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fullPhone = '$_selectedCountryCode${_mobileController.text.trim()}';
      final users = FirebaseFirestore.instance.collection('users');
      final query =
          await users.where('phone_full', isEqualTo: fullPhone).limit(1).get();

      if (query.docs.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('No account found for this mobile number');
        }
        return;
      }
      final doc = query.docs.first;
      final storedHash =
          doc.data().containsKey('pin_hash')
              ? doc.get('pin_hash') as String
              : null;
      if (storedHash == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Account has no PIN set. Try sign up or reset PIN.');
        }
        return;
      }
      final enteredHash =
          sha256.convert(utf8.encode(_pinController.text)).toString();
      if (enteredHash != storedHash) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Incorrect PIN');
        }
        return;
      }
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Logged in successfully');
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => OtpVerificationSigninScreen(
                  phoneNumber: _mobileController.text,
                  countryCode: _selectedCountryCode,
                ),
            transitionsBuilder:
                (_, a, __, child) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: a, curve: Curves.easeOut),
                    ),
                    child: child,
                  ),
                ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to login. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
            // Animated orbs
            Positioned(
              top: -100,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder:
                    (context, child) => Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(
                              0.12 * _pulseController.value,
                            ),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder:
                    (context, child) => Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(
                              0.08 * (1 - _pulseController.value),
                            ),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            // Glass accents
            Positioned(
              top: 100,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 260,
              right: 30,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          // Header
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.5, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.25),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.agriculture_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Welcome\nBack',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '👋  Sign in to continue to Krishi Sakhi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          // Form Card
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0D4017,
                                    ).withOpacity(0.25),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                    spreadRadius: -8,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phone Number
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'PHONE NUMBER',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _mobileFocusNode.hasFocus
                                                ? const Color(0xFF1B5E20)
                                                : Colors.grey.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            _mobileFocusNode.hasFocus
                                                ? const Color(0xFF2E7D32)
                                                : Colors.grey.shade200,
                                        width:
                                            _mobileFocusNode.hasFocus ? 2 : 1.5,
                                      ),
                                      color:
                                          _mobileFocusNode.hasFocus
                                              ? const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.04)
                                              : Colors.grey.shade50,
                                      boxShadow:
                                          _mobileFocusNode.hasFocus
                                              ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF2E7D32,
                                                  ).withOpacity(0.1),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2E7D32,
                                            ).withOpacity(0.06),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(14),
                                                  bottomLeft: Radius.circular(
                                                    14,
                                                  ),
                                                ),
                                          ),
                                          child: DropdownButton<String>(
                                            value: _selectedCountryCode,
                                            underline: const SizedBox(),
                                            isDense: true,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            items:
                                                _countryCodes
                                                    .map(
                                                      (c) => DropdownMenuItem(
                                                        value: c['code'],
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              c['flag']!,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Text(
                                                              c['code']!,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                  0xFF1B5E20,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged:
                                                (v) => setState(
                                                  () =>
                                                      _selectedCountryCode = v!,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: Colors.grey.shade200,
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _mobileController,
                                            focusNode: _mobileFocusNode,
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                10,
                                              ),
                                            ],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1B5E20),
                                              letterSpacing: 1,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '98765 43210',
                                              hintStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 15,
                                                  ),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // PIN
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'PIN',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _pinFocusNode.hasFocus
                                                ? const Color(0xFF1B5E20)
                                                : Colors.grey.shade700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            _pinFocusNode.hasFocus
                                                ? const Color(0xFF2E7D32)
                                                : Colors.grey.shade200,
                                        width: _pinFocusNode.hasFocus ? 2 : 1.5,
                                      ),
                                      color:
                                          _pinFocusNode.hasFocus
                                              ? const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.04)
                                              : Colors.grey.shade50,
                                      boxShadow:
                                          _pinFocusNode.hasFocus
                                              ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF2E7D32,
                                                  ).withOpacity(0.1),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                    ),
                                    child: TextField(
                                      controller: _pinController,
                                      focusNode: _pinFocusNode,
                                      obscureText: !_isPinVisible,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1B5E20),
                                        letterSpacing: _isPinVisible ? 6 : 8,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '• • • •',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          letterSpacing: 8,
                                          fontSize: 18,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 15,
                                            ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color:
                                              _pinFocusNode.hasFocus
                                                  ? const Color(0xFF2E7D32)
                                                  : Colors.grey.shade500,
                                          size: 20,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed:
                                              () => setState(
                                                () =>
                                                    _isPinVisible =
                                                        !_isPinVisible,
                                              ),
                                          icon: Icon(
                                            _isPinVisible
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                            color: Colors.grey.shade400,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Forgot PIN?',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Login Button
                                  ScaleTransition(
                                    scale: _buttonScale,
                                    child: GestureDetector(
                                      onTapDown:
                                          (_) =>
                                              _buttonScaleController.forward(),
                                      onTapUp: (_) {
                                        _buttonScaleController.reverse();
                                        if (!_isLoading) _handleLogin();
                                      },
                                      onTapCancel:
                                          () =>
                                              _buttonScaleController.reverse(),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: double.infinity,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          gradient:
                                              _isLoading
                                                  ? null
                                                  : const LinearGradient(
                                                    colors: [
                                                      Color(0xFF2E7D32),
                                                      Color(0xFF1B5E20),
                                                    ],
                                                  ),
                                          color:
                                              _isLoading
                                                  ? Colors.grey.shade300
                                                  : null,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow:
                                              _isLoading
                                                  ? []
                                                  : [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF2E7D32,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 20,
                                                      offset: const Offset(
                                                        0,
                                                        8,
                                                      ),
                                                    ),
                                                  ],
                                        ),
                                        child: Center(
                                          child:
                                              _isLoading
                                                  ? const SizedBox(
                                                    height: 22,
                                                    width: 22,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Text(
                                                        'Sign In',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'or',
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (_, __, ___) =>
                                                          const SignupScreen(),
                                                  transitionsBuilder:
                                                      (
                                                        _,
                                                        a,
                                                        __,
                                                        child,
                                                      ) => FadeTransition(
                                                        opacity: a,
                                                        child: SlideTransition(
                                                          position: Tween(
                                                            begin: const Offset(
                                                              0.08,
                                                              0,
                                                            ),
                                                            end: Offset.zero,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent: a,
                                                              curve:
                                                                  Curves
                                                                      .easeOut,
                                                            ),
                                                          ),
                                                          child: child,
                                                        ),
                                                      ),
                                                  transitionDuration:
                                                      const Duration(
                                                        milliseconds: 400,
                                                      ),
                                                ),
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: Color(0xFF1B5E20),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
