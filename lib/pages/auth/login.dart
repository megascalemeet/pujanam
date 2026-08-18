// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    mobileController.dispose();
    otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 180; // 3 minutes
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> handleSendOtp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp('+91${mobileController.text}');
    if (success) {
      _startResendCooldown();
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage!,
            style: const TextStyle(fontSize: 16, fontFamily: 'Poppins', color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> handleVerifyOtp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      '+91${mobileController.text}',
      otpController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login Successful!',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins', color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage!,
            style: const TextStyle(fontSize: 16, fontFamily: 'Poppins', color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
      otpController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = context.watch<AuthProvider>();
    const primaryColor = Color.fromRGBO(111, 10, 15, 1);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: size.height * 0.3,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        color: primaryColor,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              color: Colors.white,
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.error,
                                    color: Colors.black,
                                    size: 80,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.63,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        clipBehavior: Clip.hardEdge,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainNavigationScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Skip Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: mobileController,
                                        keyboardType: TextInputType.number,
                                        enabled: !authProvider.isOtpSent,
                                        style: const TextStyle(fontFamily: 'Poppins'),
                                        decoration: InputDecoration(
                                          labelText: 'Mobile Number',
                                          labelStyle: const TextStyle(fontFamily: 'Poppins'),
                                          hintText: 'Enter your whatsapp mobile number',
                                          hintStyle: const TextStyle(fontFamily: 'Poppins'),
                                          prefixIcon: const Icon(
                                            Icons.person,
                                            color: primaryColor,
                                          ),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          focusedBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            borderSide: BorderSide(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Please enter your whatsapp mobile number';
                                          }
                                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
                                            return 'Please enter a valid 10-digit mobile number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if (authProvider.isOtpSent) ...[
                                  const SizedBox(height: 20),
                                  AnimatedOpacity(
                                    opacity: authProvider.isOtpSent ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enter Whatsapp OTP sent to +91${mobileController.text}',
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: otpController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(fontFamily: 'Poppins'),
                                          decoration: InputDecoration(
                                            labelText: 'OTP',
                                            labelStyle: const TextStyle(fontFamily: 'Poppins'),
                                            hintText: 'Enter the 6-digit OTP',
                                            hintStyle: const TextStyle(fontFamily: 'Poppins'),
                                            prefixIcon: const Icon(
                                              Icons.lock_outline,
                                              color: primaryColor,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'Please enter the OTP';
                                            }
                                            if (!RegExp(r'^[0-9]{6}$').hasMatch(value!)) {
                                              return 'OTP must be 6 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: authProvider.isLoading
                                                  ? null
                                                  : () => authProvider.resetOtpStatus(),
                                              child: const Text(
                                                'Change Number',
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                            _resendCooldown > 0
                                                ? Text(
                                                    'Resend in $_resendCooldown s',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  )
                                                : TextButton(
                                                    onPressed: authProvider.isLoading
                                                        ? null
                                                        : handleSendOtp,
                                                    child: const Text(
                                                      'Resend OTP',
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight: FontWeight.w600,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.green.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'OTP sent on WhatsApp from 8128109049',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!.validate()) {
                                              if (!authProvider.isOtpSent) {
                                                handleSendOtp();
                                              } else {
                                                handleVerifyOtp();
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: authProvider.isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            authProvider.isOtpSent
                                                ? 'VERIFY OTP'
                                                : 'SEND OTP',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
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

