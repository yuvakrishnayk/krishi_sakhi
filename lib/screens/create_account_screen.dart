import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'signup_otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  String _selectedCountryCode = '+91';
  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;
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

    for (final node in [
      _nameFocusNode,
      _mobileFocusNode,
      _pinFocusNode,
      _confirmPinFocusNode,
    ]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _nameFocusNode.dispose();
    _mobileFocusNode.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_nameController.text.length < 3) {
      _showError('Name must be at least 3 characters');
      return;
    }
    if (_mobileController.text.isEmpty) {
      _showError('Please enter your mobile number');
      return;
    }
    if (_mobileController.text.length != 10) {
      _showError('Enter valid 10-digit number');
      return;
    }
    if (_pinController.text.isEmpty) {
      _showError('Please enter a PIN');
      return;
    }
    if (_pinController.text.length != 4) {
      _showError('PIN must be 4 digits');
      return;
    }
    if (_confirmPinController.text.isEmpty) {
      _showError('Please confirm your PIN');
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      _showError('PINs do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _saveUserToFirestore();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccess(
        'Account created. OTP sent to $_selectedCountryCode${_mobileController.text}',
      );
      Future.delayed(const Duration(milliseconds: 800)).then((_) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => OtpVerificationScreen(
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
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.toString().contains('phone-already-registered')) {
        _showError('This mobile number is already registered');
      } else {
        _showError('Failed to create account. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to create account. Please try again.');
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

  Future<String> _saveUserToFirestore() async {
    final users = FirebaseFirestore.instance.collection('users');
    final fullPhone = '$_selectedCountryCode${_mobileController.text.trim()}';
    final existing =
        await users.where('phone_full', isEqualTo: fullPhone).limit(1).get();
    if (existing.docs.isNotEmpty) throw Exception('phone-already-registered');
    final hashedPin =
        sha256.convert(utf8.encode(_pinController.text)).toString();
    final docRef = await users.add({
      'name': _nameController.text.trim(),
      'country_code': _selectedCountryCode,
      'phone': _mobileController.text.trim(),
      'phone_full': fullPhone,
      'pin_hash': hashedPin,
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefix,
  }) {
    final isFocused = focusNode.hasFocus;
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isFocused ? const Color(0xFF1B5E20) : Colors.grey.shade700,
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
                  isFocused
                      ? const Color(0xFF2E7D32)
                      : hasValue
                      ? const Color(0xFF2E7D32).withOpacity(0.3)
                      : Colors.grey.shade200,
              width: isFocused ? 2 : 1.5,
            ),
            color:
                isFocused
                    ? const Color(0xFF2E7D32).withOpacity(0.04)
                    : Colors.grey.shade50,
            boxShadow:
                isFocused
                    ? [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            children: [
              if (prefix != null) prefix,
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  inputFormatters: formatters,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                    letterSpacing: obscureText ? 6 : 0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    prefixIcon:
                        prefix == null
                            ? AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                icon,
                                color:
                                    isFocused
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey.shade500,
                                size: 20,
                              ),
                            )
                            : null,
                    suffixIcon: suffixIcon,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
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
            // Subtle pattern overlay
            Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
            // Animated orb top-right
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
            // Animated orb bottom-left
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
            // Glassmorphism accent shape
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
              top: 220,
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
                        children: [
                          const SizedBox(height: 16),
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
                                // Logo with glassmorphism
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
                                  'Join\nKrishi Sakhi',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.15,
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
                                    '🌱  Create your account to get started',
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
                          const SizedBox(height: 28),
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
                                  // Name
                                  _buildInputField(
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    label: 'FULL NAME',
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 18),
                                  // Phone
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
                                  _buildInputField(
                                    controller: _pinController,
                                    focusNode: _pinFocusNode,
                                    label: 'CREATE PIN',
                                    hint: '• • • •',
                                    icon: Icons.lock_outline_rounded,
                                    keyboardType: TextInputType.number,
                                    obscureText: !_isPinVisible,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _isPinVisible = !_isPinVisible,
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
                                  const SizedBox(height: 18),
                                  // Confirm PIN
                                  _buildInputField(
                                    controller: _confirmPinController,
                                    focusNode: _confirmPinFocusNode,
                                    label: 'CONFIRM PIN',
                                    hint: '• • • •',
                                    icon: Icons.lock_outline_rounded,
                                    keyboardType: TextInputType.number,
                                    obscureText: !_isConfirmPinVisible,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _isConfirmPinVisible =
                                                    !_isConfirmPinVisible,
                                          ),
                                      icon: Icon(
                                        _isConfirmPinVisible
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Sign Up Button
                                  ScaleTransition(
                                    scale: _buttonScale,
                                    child: GestureDetector(
                                      onTapDown:
                                          (_) =>
                                              _buttonScaleController.forward(),
                                      onTapUp: (_) {
                                        _buttonScaleController.reverse();
                                        if (!_isLoading) _handleSignup();
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
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
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
                                                        'Create Account',
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
                                  // Divider
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
                                  // Login link
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Already have an account? ",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
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
                                              'Sign In',
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
