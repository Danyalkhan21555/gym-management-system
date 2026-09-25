import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../viewmodel/dashboard_stats_viewmodel.dart';
import '../widgets/admin_announcement_card.dart';
import '../widgets/admin_stat_card.dart';
import '../../../announcements/view/manage_announcement_screen.dart';
import '../../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../../authentication/viewmodel/auth_viewmodel.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AnnouncementViewModel>();
      viewModel.loadAnnouncement();
      context.read<DashboardStatsViewModel>().loadStats();
    });
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dt.year, dt.month, dt.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${dt.day} ${_monthName(dt.month)}';
    }
  }

  /// Opens the ManageAnnouncementScreen and reloads the announcement
  /// when the user returns. This ensures the Home tab reflects any
  /// add / edit / delete performed on that screen.
  Future<void> _openManageScreen() async {
    final authVm = context.read<AuthViewModel>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageAnnouncementScreen(
          adminUid: authVm.userProfile!.uid,
          adminName: authVm.userProfile!.name,
        ),
      ),
    );

    // Reload after returning, so new / updated / deleted data shows.
    if (mounted) {
      context.read<AnnouncementViewModel>().loadAnnouncement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnnouncementViewModel>();
    final statsVm = context.watch<DashboardStatsViewModel>();
    final stats = statsVm.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──
              const Text(
                'Hello, Admin 👋',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark, // #151A1A
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary, // #7A7A7A
                ),
              ),

              const SizedBox(height: 28),

              // ── Row 1: two stat cards ──
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.people_outline,
                      number: stats.totalMembers.toString(),
                      label: 'Members',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.check_circle_outline,
                      number: stats.activeMembers.toString(),
                      label: 'Active',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Row 2: two stat cards ──
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.badge_outlined,
                      number: stats.totalStaff.toString(),
                      label: 'Staff',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.person_add_alt_1_outlined,
                      number: stats.newMembersThisMonth.toString().padLeft(2, '0'),
                      label: 'New This Month',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Section header ──
              Row(
                children: [
                  const Text(
                    'Latest Announcement',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark, // #151A1A
                    ),
                  ),
                  const Spacer(),
                  if (!viewModel.isLoading && viewModel.hasAnnouncement)
                    TextButton(
                      onPressed: _openManageScreen,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Manage',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Announcement section ──
              if (viewModel.isLoading)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (viewModel.hasAnnouncement)
                AdminAnnouncementCard(
                  announcementText: viewModel.announcement!.content,
                  dateLabel: _formatDate(viewModel.announcement!.updatedAt),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.campaign_outlined,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No announcement yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap "Add Announcement" below to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openManageScreen,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Add Announcement',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.dark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
