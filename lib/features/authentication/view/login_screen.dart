import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_background.dart';
import '../../../shared/widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = AuthProvider.of(context);
      viewModel.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthProvider.of(context);
    final isLoading = viewModel.isLoading;
    final errorMessage = viewModel.errorMessage;

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── 3. TOP HERO: 3D Element (~120x120px) ───
                    _buildHero3DElement(),

                    const SizedBox(height: 28),

                    // ─── 4. LOGIN CARD: GlassCard (~340px, padding 24, radius 32) ───
                    GlassCard(
                      width: 350,
                      borderRadius: 32,
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          // Top Edge Specular Lighting Hairline
                          Positioned(
                            top: 0,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Card Content
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // a) "Welcome Back" Heading + Neon Dot
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Welcome Back',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.8),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // b) Subtitle "Sign in to continue"
                                  Text(
                                    'Sign in to continue your fitness journey',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(
                                        alpha: 0.60,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 24),

                                  // Error Message Area (if present)
                                  if (errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFF4D4D,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFFF4D4D,
                                          ).withValues(alpha: 0.45),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: Color(0xFFFF4D4D),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              errorMessage,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFFFF4D4D),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // c) Email field (Glass style)
                                  Text(
                                    'ATHLETIC IDENTITY',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: const Color(
                                        0xFFBBCAC6,
                                      ).withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: !isLoading,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(
                                        0xFF181C22,
                                      ).withValues(alpha: 0.70),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                      hintText: 'you@gym.com',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(
                                          0xFFBBCAC6,
                                        ).withValues(alpha: 0.40),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFFBBCAC6),
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF4D4D),
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF4D4D),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // d) Password field (Glass style + eye toggle)
                                  Text(
                                    'PASSKEY ACCESS',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: const Color(
                                        0xFFBBCAC6,
                                      ).withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: !isLoading,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(
                                        0xFF181C22,
                                      ).withValues(alpha: 0.70),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                      hintText: '••••••••',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(
                                          0xFFBBCAC6,
                                        ).withValues(alpha: 0.40),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFFBBCAC6),
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFFBBCAC6),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF4D4D),
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF4D4D),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  // e) "Forgot Password?" Link (lime green, right-aligned)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Password recovery will be available soon.',
                                              style: GoogleFonts.inter(),
                                            ),
                                            backgroundColor: const Color(
                                              0xFF1C2026,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // f) Login Button (LinearGradient #C6FF00 -> #A3E635, glow, radius 16, h 56)
                                  Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient:
                                          isLoading
                                              ? LinearGradient(
                                                colors: [
                                                  AppColors.primary.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  const Color(
                                                    0xFFA3E635,
                                                  ).withValues(alpha: 0.5),
                                                ],
                                              )
                                              : const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFFC6FF00),
                                                  Color(0xFFA3E635),
                                                ],
                                              ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.40,
                                          ),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: isLoading ? null : _handleLogin,
                                        child: Center(
                                          child:
                                              isLoading
                                                  ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 3,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(AppColors.dark),
                                                        ),
                                                  )
                                                  : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Sign In',
                                                        style:
                                                            GoogleFonts
                                                                .spaceGrotesk(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  AppColors
                                                                      .dark,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Icon(
                                                        Icons.bolt_rounded,
                                                        color: AppColors.dark,
                                                        size: 22,
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── 6. BELOW CARD: Contact Admin Link ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.60),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please contact your gym administrator for access.',
                                  style: GoogleFonts.inter(),
                                ),
                                backgroundColor: const Color(0xFF1C2026),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Contact your admin',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
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
    );
  }

  /// 3D Hero Dumbbell Element (~120x120px) with depth, specular rim, and sparkles
  Widget _buildHero3DElement() {
    return SizedBox(
      width: 140,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Sparkle Stars around Hero
          Positioned(
            top: 2,
            left: 12,
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.primary.withValues(alpha: 0.9),
            ),
          ),
          Positioned(
            bottom: 14,
            right: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 12,
              color: const Color(0xFF4FDBC8).withValues(alpha: 0.8),
            ),
          ),

          // Ground Contact Shadow
          Positioned(
            bottom: 4,
            child: Container(
              width: 110,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),

          // Main 3D Glass Container
          Container(
            width: 112,
            height: 112,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 0.9,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  const Color(0xFF14B8A6).withValues(alpha: 0.15),
                  const Color(0xFF10141A).withValues(alpha: 0.90),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Specular Highlight arc
                Positioned(
                  top: 10,
                  left: 18,
                  child: Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.65),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Layered Tilted Dumbbell
                Transform.rotate(
                  angle: -0.22, // -12 degrees tilt matching Stitch
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left Outer Plate
                      _buildMiniPlate(height: 48, width: 11, isOuter: true),
                      const SizedBox(width: 2),
                      // Left Inner Plate
                      _buildMiniPlate(height: 38, width: 8, isOuter: false),

                      // Central Shaft
                      Container(
                        width: 38,
                        height: 9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4FDBC8),
                              Color(0xFFBEF500),
                              Color(0xFF4FDBC8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            height: 1.2,
                            width: 30,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),

                      // Right Inner Plate
                      _buildMiniPlate(
                        height: 38,
                        width: 8,
                        isOuter: false,
                        isTeal: true,
                      ),
                      const SizedBox(width: 2),
                      // Right Outer Plate
                      _buildMiniPlate(
                        height: 48,
                        width: 11,
                        isOuter: true,
                        isTeal: true,
                      ),
                    ],
                  ),
                ),

                // Center Bioluminescent Core Glow
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10141A).withValues(alpha: 0.6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dumbbell plate with glass gradient
  Widget _buildMiniPlate({
    required double height,
    required double width,
    required bool isOuter,
    bool isTeal = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.65),
            isTeal
                ? const Color(0xFF14B8A6).withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.35),
            const Color(0xFF0A0E14).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color:
              isTeal
                  ? const Color(0xFF4FDBC8).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
    );
  }
}

