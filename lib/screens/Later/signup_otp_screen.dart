// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:ui';

// import 'package:krishi_sakhi/screens/profile_completion_screen.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String countryCode;

//   const OtpVerificationScreen({
//     super.key,
//     required this.phoneNumber,
//     required this.countryCode,
//   });

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen>
//     with TickerProviderStateMixin {
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

//   bool _isLoading = false;
//   bool _canResend = false;
//   int _resendTimer = 30;
//   Timer? _timer;
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _pulseController;
//   late AnimationController _shakeController;
//   late AnimationController _buttonScaleController;
//   late Animation<double> _buttonScale;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 900),
//       vsync: this,
//     );
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat(reverse: true);
//     _shakeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _buttonScaleController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _buttonScale = Tween<double>(begin: 1.0, end: 0.96).animate(
//       CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
//     );

//     _fadeController.forward();
//     _slideController.forward();
//     _startResendTimer();

//     for (final node in _otpFocusNodes) {
//       node.addListener(() => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     for (var c in _otpControllers) c.dispose();
//     for (var n in _otpFocusNodes) n.dispose();
//     _timer?.cancel();
//     _fadeController.dispose();
//     _slideController.dispose();
//     _pulseController.dispose();
//     _shakeController.dispose();
//     _buttonScaleController.dispose();
//     super.dispose();
//   }

//   void _startResendTimer() {
//     setState(() {
//       _canResend = false;
//       _resendTimer = 30;
//     });
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_resendTimer > 0)
//           _resendTimer--;
//         else {
//           _canResend = true;
//           timer.cancel();
//         }
//       });
//     });
//   }

//   Future<void> _handleVerifyOtp() async {
//     FocusScope.of(context).unfocus();
//     String otp = _otpControllers.map((c) => c.text).join();
//     if (otp.length != 6) {
//       _showError('Please enter complete 6-digit OTP');
//       _shakeOtpFields();
//       return;
//     }

//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(seconds: 1));
//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     if (otp != '123456') {
//       _showError('Invalid OTP. Please try again.');
//       _shakeOtpFields();
//       for (var c in _otpControllers) c.clear();
//       _otpFocusNodes[0].requestFocus();
//       return;
//     }

//     _showSuccess('Phone number verified successfully! 🎉');
//     Future.delayed(const Duration(seconds: 1)).then((_) {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder:
//               (_, __, ___) => ProfileCompletionScreen(
//                 phoneNumber: widget.phoneNumber,
//                 countryCode: widget.countryCode,
//                 name: 'User',
//               ),
//           transitionsBuilder:
//               (_, a, __, child) => FadeTransition(opacity: a, child: child),
//           transitionDuration: const Duration(milliseconds: 400),
//         ),
//       );
//     });
//   }

//   Future<void> _handleResendOtp() async {
//     if (!_canResend) return;
//     _showSuccess('OTP sent successfully!');
//     _startResendTimer();
//     for (var c in _otpControllers) c.clear();
//     _otpFocusNodes[0].requestFocus();
//   }

//   void _shakeOtpFields() {
//     _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.error_outline_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE53935),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.check_circle_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF2E7D32),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   int get _filledCount =>
//       _otpControllers.where((c) => c.text.isNotEmpty).length;

//   Widget _buildOtpField(int index) {
//     final isFocused = _otpFocusNodes[index].hasFocus;
//     final hasValue = _otpControllers[index].text.isNotEmpty;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: 50,
//       height: 58,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color:
//               isFocused
//                   ? const Color(0xFF2E7D32)
//                   : hasValue
//                   ? const Color(0xFF2E7D32).withOpacity(0.4)
//                   : Colors.grey.shade300,
//           width: isFocused ? 2.5 : 1.5,
//         ),
//         color:
//             isFocused
//                 ? const Color(0xFF2E7D32).withOpacity(0.05)
//                 : hasValue
//                 ? const Color(0xFF2E7D32).withOpacity(0.03)
//                 : Colors.grey.shade50,
//         boxShadow:
//             isFocused
//                 ? [
//                   BoxShadow(
//                     color: const Color(0xFF2E7D32).withOpacity(0.15),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//                 : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//       ),
//       child: TextField(
//         controller: _otpControllers[index],
//         focusNode: _otpFocusNodes[index],
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//         style: const TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w800,
//           color: Color(0xFF1B5E20),
//         ),
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           counterText: '',
//           contentPadding: EdgeInsets.zero,
//         ),
//         onChanged: (value) {
//           setState(() {});
//           if (value.isNotEmpty && index < 5)
//             _otpFocusNodes[index + 1].requestFocus();
//           if (value.isEmpty && index > 0)
//             _otpFocusNodes[index - 1].requestFocus();
//           if (index == 5 &&
//               value.isNotEmpty &&
//               _otpControllers.every((c) => c.text.isNotEmpty)) {
//             Future.delayed(
//               const Duration(milliseconds: 300),
//               () => _handleVerifyOtp(),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildProgressIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(3, (i) {
//         final isActive = i <= 1;
//         final isCurrent = i == 1;
//         return Row(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: isCurrent ? 28 : 10,
//               height: 10,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
//               ),
//             ),
//             if (i < 2) const SizedBox(width: 6),
//           ],
//         );
//       }),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
//             stops: [0.0, 0.4, 1.0],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
//             Positioned(
//               top: -100,
//               right: -80,
//               child: AnimatedBuilder(
//                 animation: _pulseController,
//                 builder:
//                     (ctx, _) => Container(
//                       width: 280,
//                       height: 280,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: RadialGradient(
//                           colors: [
//                             Colors.white.withOpacity(
//                               0.12 * _pulseController.value,
//                             ),
//                             Colors.white.withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//               ),
//             ),
//             Positioned(
//               bottom: -140,
//               left: -80,
//               child: AnimatedBuilder(
//                 animation: _pulseController,
//                 builder:
//                     (ctx, _) => Container(
//                       width: 320,
//                       height: 320,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: RadialGradient(
//                           colors: [
//                             Colors.white.withOpacity(
//                               0.08 * (1 - _pulseController.value),
//                             ),
//                             Colors.white.withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//               ),
//             ),
//             SafeArea(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     minHeight:
//                         screenHeight -
//                         MediaQuery.of(context).padding.top -
//                         MediaQuery.of(context).padding.bottom,
//                   ),
//                   child: FadeTransition(
//                     opacity: _fadeController,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 16),
//                           // Top bar
//                           SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(-0.5, 0),
//                               end: Offset.zero,
//                             ).animate(
//                               CurvedAnimation(
//                                 parent: _slideController,
//                                 curve: Curves.easeOutCubic,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () => Navigator.pop(context),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(14),
//                                     child: BackdropFilter(
//                                       filter: ImageFilter.blur(
//                                         sigmaX: 10,
//                                         sigmaY: 10,
//                                       ),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(10),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.15),
//                                           borderRadius: BorderRadius.circular(
//                                             14,
//                                           ),
//                                           border: Border.all(
//                                             color: Colors.white.withOpacity(
//                                               0.2,
//                                             ),
//                                           ),
//                                         ),
//                                         child: const Icon(
//                                           Icons.arrow_back_rounded,
//                                           color: Colors.white,
//                                           size: 22,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 _buildProgressIndicator(),
//                                 const SizedBox(width: 44),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           // Header
//                           SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(-0.5, 0),
//                               end: Offset.zero,
//                             ).animate(
//                               CurvedAnimation(
//                                 parent: _slideController,
//                                 curve: Curves.easeOutCubic,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: BackdropFilter(
//                                     filter: ImageFilter.blur(
//                                       sigmaX: 12,
//                                       sigmaY: 12,
//                                     ),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(14),
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             Colors.white.withOpacity(0.25),
//                                             Colors.white.withOpacity(0.1),
//                                           ],
//                                         ),
//                                         borderRadius: BorderRadius.circular(20),
//                                         border: Border.all(
//                                           color: Colors.white.withOpacity(0.3),
//                                           width: 1.5,
//                                         ),
//                                       ),
//                                       child: const Icon(
//                                         Icons.verified_user_rounded,
//                                         color: Colors.white,
//                                         size: 32,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 const Text(
//                                   'Verify\nPhone',
//                                   style: TextStyle(
//                                     fontSize: 36,
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.white,
//                                     height: 1.15,
//                                     letterSpacing: -1,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.15),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     '📱  Code sent to ${widget.countryCode} ${widget.phoneNumber}',
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white.withOpacity(0.95),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           // OTP Card
//                           SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0, 0.2),
//                               end: Offset.zero,
//                             ).animate(
//                               CurvedAnimation(
//                                 parent: _slideController,
//                                 curve: Curves.easeOutCubic,
//                               ),
//                             ),
//                             child: AnimatedBuilder(
//                               animation: _shakeController,
//                               builder: (context, child) {
//                                 final offset =
//                                     8 *
//                                     (_shakeController.value < 0.5
//                                         ? _shakeController.value
//                                         : 1 - _shakeController.value);
//                                 return Transform.translate(
//                                   offset: Offset(offset, 0),
//                                   child: child,
//                                 );
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(28),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: const Color(
//                                         0xFF0D4017,
//                                       ).withOpacity(0.25),
//                                       blurRadius: 40,
//                                       offset: const Offset(0, 16),
//                                       spreadRadius: -8,
//                                     ),
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       'Enter Verification Code',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.grey.shade800,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(4),
//                                       child: AnimatedContainer(
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         height: 4,
//                                         width: double.infinity,
//                                         child: LinearProgressIndicator(
//                                           value: _filledCount / 6,
//                                           backgroundColor: Colors.grey.shade200,
//                                           valueColor:
//                                               const AlwaysStoppedAnimation<
//                                                 Color
//                                               >(Color(0xFF2E7D32)),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: List.generate(
//                                         6,
//                                         (i) => _buildOtpField(i),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           "Didn't receive? ",
//                                           style: TextStyle(
//                                             color: Colors.grey.shade600,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: _handleResendOtp,
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 8,
//                                               vertical: 4,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   _canResend
//                                                       ? const Color(
//                                                         0xFF2E7D32,
//                                                       ).withOpacity(0.08)
//                                                       : Colors.transparent,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Text(
//                                               _canResend
//                                                   ? 'Resend Code'
//                                                   : 'Resend in ${_resendTimer}s',
//                                               style: TextStyle(
//                                                 color:
//                                                     _canResend
//                                                         ? const Color(
//                                                           0xFF1B5E20,
//                                                         )
//                                                         : Colors.grey.shade500,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w800,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 24),
//                                     ScaleTransition(
//                                       scale: _buttonScale,
//                                       child: GestureDetector(
//                                         onTapDown:
//                                             (_) =>
//                                                 _buttonScaleController
//                                                     .forward(),
//                                         onTapUp: (_) {
//                                           _buttonScaleController.reverse();
//                                           if (!_isLoading) _handleVerifyOtp();
//                                         },
//                                         onTapCancel:
//                                             () =>
//                                                 _buttonScaleController
//                                                     .reverse(),
//                                         child: AnimatedContainer(
//                                           duration: const Duration(
//                                             milliseconds: 200,
//                                           ),
//                                           width: double.infinity,
//                                           height: 54,
//                                           decoration: BoxDecoration(
//                                             gradient:
//                                                 _isLoading
//                                                     ? null
//                                                     : const LinearGradient(
//                                                       colors: [
//                                                         Color(0xFF2E7D32),
//                                                         Color(0xFF1B5E20),
//                                                       ],
//                                                     ),
//                                             color:
//                                                 _isLoading
//                                                     ? Colors.grey.shade300
//                                                     : null,
//                                             borderRadius: BorderRadius.circular(
//                                               16,
//                                             ),
//                                             boxShadow:
//                                                 _isLoading
//                                                     ? []
//                                                     : [
//                                                       BoxShadow(
//                                                         color: const Color(
//                                                           0xFF2E7D32,
//                                                         ).withOpacity(0.4),
//                                                         blurRadius: 20,
//                                                         offset: const Offset(
//                                                           0,
//                                                           8,
//                                                         ),
//                                                       ),
//                                                     ],
//                                           ),
//                                           child: Center(
//                                             child:
//                                                 _isLoading
//                                                     ? const SizedBox(
//                                                       height: 22,
//                                                       width: 22,
//                                                       child: CircularProgressIndicator(
//                                                         strokeWidth: 2.5,
//                                                         valueColor:
//                                                             AlwaysStoppedAnimation<
//                                                               Color
//                                                             >(Colors.white),
//                                                       ),
//                                                     )
//                                                     : Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: const [
//                                                         Text(
//                                                           'Verify & Continue',
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.w700,
//                                                             color: Colors.white,
//                                                             letterSpacing: 0.3,
//                                                           ),
//                                                         ),
//                                                         SizedBox(width: 8),
//                                                         Icon(
//                                                           Icons
//                                                               .arrow_forward_rounded,
//                                                           color: Colors.white,
//                                                           size: 20,
//                                                         ),
//                                                       ],
//                                                     ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 18),
//                                     Container(
//                                       padding: const EdgeInsets.all(12),
//                                       decoration: BoxDecoration(
//                                         color: const Color(
//                                           0xFF2E7D32,
//                                         ).withOpacity(0.06),
//                                         borderRadius: BorderRadius.circular(12),
//                                         border: Border.all(
//                                           color: const Color(
//                                             0xFF2E7D32,
//                                           ).withOpacity(0.12),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.all(4),
//                                             decoration: BoxDecoration(
//                                               color: const Color(
//                                                 0xFF2E7D32,
//                                               ).withOpacity(0.1),
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                             child: const Icon(
//                                               Icons.schedule_rounded,
//                                               color: Color(0xFF2E7D32),
//                                               size: 16,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: Text(
//                                               'Code expires in 10 minutes',
//                                               style: TextStyle(
//                                                 fontSize: 13,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Colors.grey.shade700,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DotPatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white.withOpacity(0.03);
//     const spacing = 30.0;
//     for (double x = 0; x < size.width; x += spacing) {
//       for (double y = 0; y < size.height; y += spacing) {
//         canvas.drawCircle(Offset(x, y), 1, paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
