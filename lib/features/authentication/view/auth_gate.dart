import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/view/admin_dashboard_screen.dart';
import '../../member/view/member_dashboard_screen.dart';
import '../../receptionist/view/receptionist_dashboard_screen.dart';
import '../../trainer/view/trainer_dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthGateContent();
  }
}

class _AuthGateContent extends StatelessWidget {
  const _AuthGateContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthProvider.of(context);

    if (!viewModel.hasCheckedCurrentUser) {
      return const _SplashScreen();
    }

    if (viewModel.currentUser == null) {
      return const LoginScreen();
    }

    if (viewModel.userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    final role = viewModel.userProfile!.role;
    Widget panel;

    switch (role) {
      case 'admin':
        panel = const AdminDashboardScreen();
        break;
      case 'receptionist':
        panel = const ReceptionistDashboardScreen();
        break;
      case 'trainer':
        panel = const TrainerDashboardScreen();
        break;
      case 'member':
        panel = const MemberDashboardScreen();
        break;
      default:
        panel = const Center(child: Text('Unknown user role'));
    }

    return Scaffold(body: panel);
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── 1. Background Atmosphere: Dark gradient + Lime/Teal glows ───
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1117),
                  Color(0xFF091410),
                  Color(0xFF0D1117),
                ],
              ),
            ),
          ),

          // Lime Glow Top-Left
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Teal Glow Bottom-Right
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF14B8A6).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle Purple Accent Center-Right
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B21A8).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Main Content ───
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Smooth floating bob oscillation (0 -> -12 -> 0)
                final floatOffset =
                    (_floatAnimation.value <= -6)
                        ? (_floatAnimation.value * 2 + 12)
                        : _floatAnimation.value * 2;

                return Column(
                  children: [
                    const Spacer(flex: 3),

                    // ─── 2. Center: 3D Element ───
                    _build3DElement(floatOffset),

                    const SizedBox(height: 28),

                    // ─── 3. "GymOS" Logo Text (Space Grotesk, 36px, 800, white/lime gradient) ───
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Color(0xFFF0FDF4),
                            AppColors.primary,
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'GymOS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ─── 4. Tagline: "Manage. Train. Grow." (Inter, 13px, white 50%) ───
                    Text(
                      'Manage. Train. Grow.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.50),
                        letterSpacing: 2.2,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ─── 5. Loading Shimmer (Lime progress bar with animation) ───
                    _buildLoadingShimmer(),

                    const SizedBox(height: 16),

                    // ─── 6. "v1.0.0" at bottom (Inter, 10px, white 30%) ───
                    Text(
                      'v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.30),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 3D Element simulation using Container + multiple BoxShadows + RadialGradient
  Widget _build3DElement(double floatOffset) {
    return Transform.translate(
      offset: Offset(0, floatOffset),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic Ground Ambient Occlusion Shadow
          Positioned(
            bottom: 2,
            child: Container(
              width: 140,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),

          // Simulated 3D Glass Dumbbell Element
          Container(
            width: 130,
            height: 130,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.95,
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  const Color(0xFF14B8A6).withValues(alpha: 0.12),
                  const Color(0xFF0D1117).withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.5,
              ),
              boxShadow: [
                // Deep Isometric Drop Shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
                // Neon Lime Bioluminescent Outer Glow
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
                // Cyan Caustic Rim Glow
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner Specular Glass Glint (Top-Left)
                Positioned(
                  top: 14,
                  left: 20,
                  child: Container(
                    width: 32,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.65),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Layered 3D Dumbbell Silhouette with Depth
                Transform.rotate(
                  angle: -0.45, // -26 degrees isometric tilt
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left Outer Plate
                      _buildDumbbellPlate(height: 52, width: 13, isOuter: true),
                      const SizedBox(width: 2),
                      // Left Inner Plate
                      _buildDumbbellPlate(height: 42, width: 9, isOuter: false),

                      // Central Titanium Knurled Shaft
                      Container(
                        width: 44,
                        height: 11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0xFFD1D5DB),
                              Color(0xFF374151),
                              Color(0xFF111827),
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            height: 1.5,
                            width: 36,
                            color: AppColors.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),

                      // Right Inner Plate
                      _buildDumbbellPlate(height: 42, width: 9, isOuter: false),
                      const SizedBox(width: 2),
                      // Right Outer Plate
                      _buildDumbbellPlate(
                        height: 52,
                        width: 13,
                        isOuter: true,
                        accentLime: true,
                      ),
                    ],
                  ),
                ),

                // Central Floating Neon Badge Monogram
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0D1117).withValues(alpha: 0.6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 18,
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

  /// Dumbbell plate with glassmorphic bevel styling
  Widget _buildDumbbellPlate({
    required double height,
    required double width,
    required bool isOuter,
    bool accentLime = false,
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
            Colors.white.withValues(alpha: 0.7),
            accentLime
                ? AppColors.primary.withValues(alpha: 0.45)
                : const Color(0xFF14B8A6).withValues(alpha: 0.35),
            const Color(0xFF0F172A).withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color:
              accentLime
                  ? AppColors.primary.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  /// Loading shimmer: lime progress bar with animated specular sweep
  Widget _buildLoadingShimmer() {
    return Container(
      width: 140,
      height: 3.5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Active Neon Lime/Teal Gradient Base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    Color(0xFF14B8A6),
                    Color(0xFF10B981),
                  ],
                ),
              ),
            ),
            // Specular Shimmer Sweep
            LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final shimmerX = _shimmerAnimation.value * barWidth;

                return Transform.translate(
                  offset: Offset(shimmerX, 0),
                  child: Container(
                    width: barWidth * 0.45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
