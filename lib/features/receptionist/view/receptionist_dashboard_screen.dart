import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/glass_background.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../../admin/repository/dashboard_stats_repository.dart';
import '../../admin/viewmodel/dashboard_stats_viewmodel.dart';
import '../../announcements/repository/announcement_repository.dart';
import '../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../member/repository/member_repository.dart';
import '../../member/viewModel/view_model.dart';
import 'tabs/receptionist_create_tab.dart';
import 'tabs/receptionist_home_tab.dart';
import 'tabs/receptionist_members_tab.dart';
import 'tabs/receptionist_profile_tab.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardStatsViewModel(DashboardStatsRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnouncementViewModel(AnnouncementRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberViewModel(MemberRepository()),
        ),
      ],
      child: GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              RepaintBoundary(
                child: ReceptionistHomeTab(
                  onAddMemberTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
              RepaintBoundary(
                child: ReceptionistMembersTab(
                  onAddMemberTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
              const RepaintBoundary(child: ReceptionistCreateTab()),
              const RepaintBoundary(child: ReceptionistProfileTab()),
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
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Members',
              ),
              GlassNavItem(
                icon: Icons.person_add_alt_1_outlined,
                activeIcon: Icons.person_add_alt_1,
                label: 'Create',
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
    );
  }
}
