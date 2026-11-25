import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable frosted glass card for glassmorphism UI.
/// Always uses dark glass — no light mode variant.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool useBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.blurSigma = 18,
    this.onTap,
    this.height,
    this.width,
    this.useBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    // The visual container (glass appearance)
    final glassContainer = Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: child,
    );

    Widget card;
    if (useBlur) {
      // REAL glass (expensive)
      card = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: glassContainer,
        ),
      );
    } else {
      // FAKE glass (fast)
      card = glassContainer;
    }

    // RepaintBoundary for list items
    if (!useBlur) {
      card = RepaintBoundary(child: card);
    }

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
