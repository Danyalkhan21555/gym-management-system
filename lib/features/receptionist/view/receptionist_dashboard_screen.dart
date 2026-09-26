import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'tabs/receptionist_create_tab.dart';
import 'tabs/receptionist_home_tab.dart';
import 'tabs/receptionist_members_tab.dart';
import 'tabs/receptionist_profile_tab.dart';

/// Main dashboard shell for Receptionists with custom 4-tab bottom navigation.
class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() =>
      _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState
    extends State<ReceptionistDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ReceptionistHomeTab(),
          ReceptionistMembersTab(),
          ReceptionistCreateTab(),
          ReceptionistProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildNavItem(
                  0,
                  'Home',
                  Icons.home,
                  Icons.home_outlined,
                ),
                _buildNavItem(
                  1,
                  'Members',
                  Icons.people,
                  Icons.people_outline,
                ),
                _buildNavItem(
                  2,
                  'Create',
                  Icons.person_add_alt_1,
                  Icons.person_add_alt_1_outlined,
                ),
                _buildNavItem(
                  3,
                  'Profile',
                  Icons.person,
                  Icons.person_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single bottom navigation item with custom active/inactive styling and dot indicator.
  Widget _buildNavItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
  ) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: 24,
              color: isSelected ? AppColors.dark : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.dark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
