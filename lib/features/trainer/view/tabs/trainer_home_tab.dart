import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/view/widgets/admin_announcement_card.dart';
import '../../../admin/view/widgets/admin_stat_card.dart';
import '../../../admin/viewmodel/dashboard_stats_viewmodel.dart';
import '../../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../../dietPlan/viewmodel/diet_plan_viewmodel.dart';

class TrainerHomeTab extends StatefulWidget {
  /// Called when the trainer taps "Write Diet Plan".
  /// The parent dashboard switches to the Diet tab (index 1).
  final VoidCallback? onWriteDietTap;

  const TrainerHomeTab({super.key, this.onWriteDietTap});

  @override
  State<TrainerHomeTab> createState() => _TrainerHomeTabState();
}

class _TrainerHomeTabState extends State<TrainerHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementViewModel>().loadAnnouncement();
      context.read<DashboardStatsViewModel>().loadStats();

      // Load trainer's own diet plans count
      final authVm = AuthProvider.of(context);
      final trainerId = authVm.userProfile?.uid;
      if (trainerId != null) {
        context.read<DietPlanViewModel>().loadPlansByTrainer(trainerId);
      }
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

  String _formatAnnouncementDate(DateTime dt) {
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

  @override
  Widget build(BuildContext context) {
    final authVm = AuthProvider.of(context);
    final statsVm = context.watch<DashboardStatsViewModel>();
    final announcementVm = context.watch<AnnouncementViewModel>();
    final dietPlanVm = context.watch<DietPlanViewModel>();
    final name = authVm.userProfile?.name ?? 'Trainer';
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
              Text(
                'Hello, $name 👋',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // ── Stat cards ──
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.people_outline,
                      number: stats.activeMembers.toString(),
                      label: 'Active Members',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminStatCard(
                      icon: Icons.restaurant_outlined,
                      number: dietPlanVm.trainerPlans.length.toString(),
                      label: 'Diet Plans',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Quick Action ──
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () => widget.onWriteDietTap?.call(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Write Diet Plan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Create or update a member\'s plan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Latest Announcement ──
              const Text(
                'Latest Announcement',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),

              if (announcementVm.isLoading)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
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
              else if (announcementVm.hasAnnouncement)
                AdminAnnouncementCard(
                  announcementText: announcementVm.announcement!.content,
                  dateLabel: _formatAnnouncementDate(
                    announcementVm.announcement!.updatedAt,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No announcement yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Check back later for updates from the admin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
