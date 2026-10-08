import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../admin/view/widgets/admin_announcement_card.dart';
import '../../../announcements/viewmodel/announcement_viewmodel.dart';
import '../../../member/model/member_model.dart';

class MemberHomeTab extends StatefulWidget {
  const MemberHomeTab({super.key});

  @override
  State<MemberHomeTab> createState() => _MemberHomeTabState();
}

class _MemberHomeTabState extends State<MemberHomeTab> {
  bool _hasShownExpiryDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementViewModel>().loadAnnouncement();
    });
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
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
    final announcementVm = context.watch<AnnouncementViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = authVm.userProfile?.name ?? 'Member';

    // TODO: Replace with real MemberModel from Firestore.
    // For now, use dummy data so UI is visible.
    final member = _dummyMember(name);

    // Show expiry popup once if critical/expired
    if (!_hasShownExpiryDialog &&
        (member.warningLevel == MembershipWarningLevel.critical ||
            member.warningLevel == MembershipWarningLevel.expired)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showExpiryDialog(context, member);
          _hasShownExpiryDialog = true;
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──
              Text(
                'Hello, $name 👋',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Warning Banner (if expiring soon) ──
              if (member.warningLevel == MembershipWarningLevel.warning ||
                  member.warningLevel == MembershipWarningLevel.critical)
                _buildWarningBanner(context, member),

              if (member.warningLevel == MembershipWarningLevel.warning ||
                  member.warningLevel == MembershipWarningLevel.critical)
                const SizedBox(height: 16),

              // ── Membership Card (hero) ──
              _buildMembershipCard(context, member, isDark),

              const SizedBox(height: 16),

              // ── Quick Actions (2 glass cards) ──
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        // TODO: navigate to Diet tab
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 22,
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Diet Plan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'View plan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        // TODO: navigate to Chat tab
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 22,
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chat',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Message trainer',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Latest Announcement ──
              Text(
                'Latest Announcement',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),

              if (announcementVm.isLoading)
                GlassCard(
                  height: 120,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
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
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 32,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No announcement yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check back later for updates from the admin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Membership Hero Card ──
  Widget _buildMembershipCard(
    BuildContext context,
    MemberModel member,
    bool isDark,
  ) {
    final warningColor = _warningColor(member.warningLevel);
    final warningLabel = _warningLabel(member.warningLevel);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Membership',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            member.planLabel,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.dark,
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progressValue(member),
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                warningColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                _formatDate(member.startDate ?? DateTime.now()),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                member.expiryDate != null
                    ? _formatDate(member.expiryDate!)
                    : '—',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Days remaining badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: warningColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _warningIcon(member.warningLevel),
                  size: 16,
                  color: warningColor,
                ),
                const SizedBox(width: 6),
                Text(
                  warningLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: warningColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Warning Banner ──
  Widget _buildWarningBanner(BuildContext context, MemberModel member) {
    final isCritical =
        member.warningLevel == MembershipWarningLevel.critical;
    final color = isCritical ? AppColors.error : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCritical
                  ? 'Your membership expires in ${member.daysRemaining} days!'
                  : 'Your membership expires in ${member.daysRemaining} days. Renew soon.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Expiry Popup Dialog ──
  void _showExpiryDialog(BuildContext context, MemberModel member) {
    final isExpired = member.warningLevel == MembershipWarningLevel.expired;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              isExpired ? Icons.error_outline : Icons.warning_amber_rounded,
              color: isExpired ? AppColors.error : const Color(0xFFF59E0B),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isExpired ? 'Membership Expired' : 'Membership Expiring',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.dark,
              ),
            ),
          ],
        ),
        content: Text(
          isExpired
              ? 'Your membership has expired. Please contact the reception desk to renew your plan and continue enjoying all features.'
              : 'Your membership expires in ${member.daysRemaining} days. Please visit the reception desk to renew your plan.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.dark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.dark,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: warning color ──
  Color _warningColor(MembershipWarningLevel level) {
    switch (level) {
      case MembershipWarningLevel.normal:
        return AppColors.primary;
      case MembershipWarningLevel.warning:
        return const Color(0xFFF59E0B);
      case MembershipWarningLevel.critical:
      case MembershipWarningLevel.expired:
        return AppColors.error;
    }
  }

  // ── Helper: warning icon ──
  IconData _warningIcon(MembershipWarningLevel level) {
    switch (level) {
      case MembershipWarningLevel.normal:
        return Icons.check_circle_outline;
      case MembershipWarningLevel.warning:
        return Icons.warning_amber_rounded;
      case MembershipWarningLevel.critical:
      case MembershipWarningLevel.expired:
        return Icons.error_outline;
    }
  }

  // ── Helper: warning label ──
  String _warningLabel(MembershipWarningLevel level) {
    // TODO: get member from Firestore for real values
    return 'Active';
  }

  // ── Helper: progress value (0 to 1) ──
  double _progressValue(MemberModel member) {
    // TODO: compute real progress from startDate/expiryDate
    return 0.5;
  }

  // ── TEMP: dummy member for UI preview ──
  MemberModel _dummyMember(String name) {
    final now = DateTime.now();
    return MemberModel(
      uid: 'dummy',
      memberId: 'MEM001',
      name: name,
      phone: '03001234567',
      status: 'active',
      plan: 'premium',
      duration: 3,
      startDate: now.subtract(const Duration(days: 60)),
      expiryDate: now.add(const Duration(days: 30)),
      createdAt: now,
    );
  }
}