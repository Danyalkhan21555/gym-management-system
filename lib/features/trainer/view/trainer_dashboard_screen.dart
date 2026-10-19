import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/glass_background.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../../announcements/repository/announcement_repository.dart';
import '../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../chat/repository/chat_repository.dart';
import '../../chat/viewmodel/chat_viewmodel.dart';
import '../../dietPlan/repository/diet_plan_repository.dart';
import '../../dietPlan/viewmodel/diet_plan_viewmodel.dart';
import '../../member/repository/member_repository.dart';
import '../../member/viewModel/view_model.dart';
import 'tabs/trainer_chat_tab.dart';
import 'tabs/trainer_diet_tab.dart';
import 'tabs/trainer_home_tab.dart';
import 'tabs/trainer_profile_tab.dart';
import '../../admin/repository/dashboard_stats_repository.dart';
import '../../admin/viewmodel/dashboard_stats_viewmodel.dart';

/// Trainer dashboard shell with persistent bottom navigation bar.
class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnnouncementViewModel(AnnouncementRepository()),
      child: ChangeNotifierProvider(
        create: (_) => MemberViewModel(MemberRepository()),
        child: ChangeNotifierProvider(
          create: (_) => DietPlanViewModel(DietPlanRepository()),
          child: ChangeNotifierProvider(
            create: (_) => ChatViewModel(ChatRepository()),
            child: ChangeNotifierProvider(
              create: (_) =>
                  DashboardStatsViewModel(DashboardStatsRepository()), // ← NEW
              child: GlassBackground(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBody: true,
                  body: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      RepaintBoundary(
                        child: TrainerHomeTab(
                          onWriteDietTap: () =>
                              setState(() => _selectedIndex = 1),
                        ),
                      ),
                      const RepaintBoundary(child: TrainerDietTab()),
                      const RepaintBoundary(child: TrainerChatTab()),
                      const RepaintBoundary(child: TrainerProfileTab()),
                    ],
                  ),
                  bottomNavigationBar: GlassBottomNav(
                    currentIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index),
                    items: const [
                      GlassNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                      ),
                      GlassNavItem(
                        icon: Icons.restaurant_outlined,
                        activeIcon: Icons.restaurant,
                        label: 'Diet',
                      ),
                      GlassNavItem(
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                        label: 'Chat',
                      ),
                      GlassNavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
