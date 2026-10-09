import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
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
import '../../staff/repository/staff_repository.dart';
import '../../staff/viewmodel/staff_viewmodel.dart';
import 'tabs/member_chat_tab.dart';
import 'tabs/member_diet_tab.dart';
import 'tabs/member_home_tab.dart';
import 'tabs/member_profile_tab.dart';

/// Member dashboard screen with persistent bottom navigation and 
/// viewmodel providers.
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
        ChangeNotifierProvider(
          create: (_) => StaffViewModel(StaffRepository()),
        ),
      ],
      // Use a Builder so we get a context INSIDE the MultiProvider.
      // This lets us safely read MemberViewModel after it's created.
      child: Builder(
        builder: (innerContext) {
          return _MemberDashboardContent(
            selectedIndex: _selectedIndex,
            onTabTapped: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}

/// The actual dashboard content, living inside the MultiProvider scope.
class _MemberDashboardContent extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabTapped;

  const _MemberDashboardContent({
    required this.selectedIndex,
    required this.onTabTapped,
  });

  @override
  State<_MemberDashboardContent> createState() =>
      _MemberDashboardContentState();
}

class _MemberDashboardContentState extends State<_MemberDashboardContent> {
  bool _memberLoadTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now we're INSIDE the MultiProvider — safe to read MemberViewModel.
    // Wait for auth profile to be ready, then trigger load once.
    if (_memberLoadTriggered) return;

    final authVm = AuthProvider.of(context);
    final uid = authVm.userProfile?.uid;
    if (uid == null) return;

    _memberLoadTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MemberViewModel>().loadMember(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: widget.selectedIndex,
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
                  context,
                  0,
                  'Home',
                  Icons.home,
                  Icons.home_outlined,
                ),
                _buildNavItem(
                  context,
                  1,
                  'Diet',
                  Icons.restaurant,
                  Icons.restaurant_outlined,
                ),
                _buildNavItem(
                  context,
                  2,
                  'Chat',
                  Icons.chat_bubble,
                  Icons.chat_bubble_outline,
                ),
                _buildNavItem(
                  context,
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

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
  ) {
    final isSelected = widget.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTabTapped(index),
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