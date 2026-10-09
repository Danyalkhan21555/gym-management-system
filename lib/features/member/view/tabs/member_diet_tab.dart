import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../dietPlan/model/diet_plan_model.dart';
import '../../../dietPlan/viewmodel/diet_plan_viewmodel.dart';

/// Member Diet Tab — read-only view of the diet plan assigned by the trainer.
class MemberDietTab extends StatefulWidget {
  const MemberDietTab({super.key});

  @override
  State<MemberDietTab> createState() => _MemberDietTabState();
}

class _MemberDietTabState extends State<MemberDietTab> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlan();
    });
  }

  Future<void> _loadPlan() async {
    final authVm = AuthProvider.of(context);
    final uid = authVm.userProfile?.uid;
    if (uid == null) return;

    await context.read<DietPlanViewModel>().loadPlan(uid);
    if (mounted) {
      setState(() => _loaded = true);
    }
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
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<DietPlanViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan = planVm.currentPlan;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diet Plan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assigned by your trainer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: !_loaded || planVm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : plan == null
                  ? _buildEmpty(context, isDark, planVm)
                  : _buildPlanView(context, plan, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmpty(
    BuildContext context,
    bool isDark,
    DietPlanViewModel planVm,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 32,
                color: isDark ? AppColors.primary : AppColors.dark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No diet plan yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your trainer hasn\'t assigned a diet plan yet. It will appear here once they do.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _loadPlan(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primary : AppColors.dark,
                side: BorderSide(
                  color: isDark ? AppColors.primary : AppColors.dark,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plan View ──
  Widget _buildPlanView(BuildContext context, DietPlanModel plan, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Trainer info card ──
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: isDark ? AppColors.primary : AppColors.dark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'By ${plan.trainerName}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Updated ${_formatDate(plan.updatedAt)}',
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Diet plan content ──
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Plan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  plan.content,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.7,
                    color: isDark ? Colors.white : AppColors.dark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Note card ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: isDark ? AppColors.primary : AppColors.dark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Follow this plan consistently. Contact your trainer via chat for any changes.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? AppColors.primary : AppColors.dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
