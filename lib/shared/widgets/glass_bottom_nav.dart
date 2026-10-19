import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Navigation item model for [GlassBottomNav].
class GlassNavItem {
  /// Outlined icon for inactive state.
  final IconData icon;

  /// Filled icon for active state.
  final IconData activeIcon;

  /// Label displayed below the icon.
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A reusable glassmorphic floating pill bottom navigation bar.
///
/// Implements the GymOS "Floating Glass Pill" design (Variant 2) with
/// 30px backdrop blur, subtle white border, floating elevation shadow,
/// and electric lime (#C6FF00) active indicators.
class GlassBottomNav extends StatelessWidget {
  /// The index of the currently active tab.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// The list of navigation tabs (3 to 4 items supported).
  final List<GlassNavItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : assert(
          items.length >= 3 && items.length <= 4,
          'GlassBottomNav requires between 3 and 4 items',
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = currentIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with active lime glow
                            Container(
                              width: 24,
                              height: 24,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    )
                                  : null,
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 24,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.6),
                                shadows: isSelected
                                    ? [
                                        Shadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Label
                            Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                height: 1.1,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Indicator dot
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
