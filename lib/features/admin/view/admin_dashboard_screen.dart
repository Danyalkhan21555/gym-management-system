import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/glass_background.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../../announcements/repository/announcement_repository.dart';
import '../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../member/repository/member_repository.dart';
import '../../member/viewModel/view_model.dart';
import '../../staff/repository/staff_repository.dart';
import '../../staff/viewmodel/staff_viewmodel.dart';
import '../repository/dashboard_stats_repository.dart';
import '../viewmodel/dashboard_stats_viewmodel.dart';
import 'tabs/admin_home_tab.dart';
import 'tabs/admin_members_tab.dart';
import 'tabs/admin_profile_tab.dart';
import 'tabs/admin_staff_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnnouncementViewModel(AnnouncementRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffViewModel(StaffRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberViewModel(MemberRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardStatsViewModel(DashboardStatsRepository()),
        ),
      ],
      child: GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              RepaintBoundary(child: AdminHomeTab()),
              RepaintBoundary(child: AdminStaffTab()),
              RepaintBoundary(child: AdminMembersTab()),
              RepaintBoundary(child: AdminProfileTab()),
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
                icon: Icons.badge_outlined,
                activeIcon: Icons.badge,
                label: 'Staff',
              ),
              GlassNavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Members',
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
