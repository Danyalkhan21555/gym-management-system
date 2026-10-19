import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Full-screen glassmorphism background for the entire app.
/// Dark gradient + radial lime/teal glows.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1117),
                Color(0xFF0A1A0F),
                Color(0xFF0D1117),
              ],
            ),
          ),
        ),

        // Lime glow top-left
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Teal glow bottom-right
        Positioned(
          bottom: 40,
          right: -40,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF14B8A6).withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}
