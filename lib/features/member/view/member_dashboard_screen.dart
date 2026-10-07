import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../admin/repository/dashboard_stats_repository.dart';
import '../../admin/viewmodel/dashboard_stats_viewmodel.dart';
import '../../announcements/repository/announcement_repository.dart';
import '../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../chat/repository/chat_repository.dart';
import '../../chat/viewmodel/chat_viewmodel.dart';
import '../../dietPlan/repository/diet_plan_repository.dart';
import '../../dietPlan/viewmodel/diet_plan_viewmodel.dart';
import '../../member/repository/member_repository.dart';
import '../../member/viewModel/view_model.dart';
import 'tabs/member_chat_tab.dart';
import 'tabs/member_diet_tab.dart';
import 'tabs/member_home_tab.dart';
import 'tabs/member_profile_tab.dart';

/// Member dashboard screen with persistent bottom navigation and viewmodel providers.
class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnnouncementViewModel(AnnouncementRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DietPlanViewModel(DietPlanRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(ChatRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardStatsViewModel(DashboardStatsRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberViewModel(MemberRepository()),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            MemberHomeTab(),
            MemberDietTab(),
            MemberChatTab(),
            MemberProfileTab(),
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
                    'Diet',
                    Icons.restaurant,
                    Icons.restaurant_outlined,
                  ),
                  _buildNavItem(
                    2,
                    'Chat',
                    Icons.chat_bubble,
                    Icons.chat_bubble_outline,
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
      ),
    );
  }

  /// Builds a bottom navigation bar item with animated indicator dot.
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
