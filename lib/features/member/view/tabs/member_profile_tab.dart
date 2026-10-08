import 'package:flutter/material.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Member Profile Tab — glass design with profile details and logout.
class MemberProfileTab extends StatelessWidget {
  const MemberProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthProvider.of(context);

    final profile = viewModel.userProfile;

    // Safe fallbacks
    final name = profile?.name ?? 'Member';
    final profileId = profile?.profileId ?? '';
    final role = profile?.role ?? 'member';
    final status = profile?.status ?? 'active';

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ── Avatar + Name ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Account Info Card ──
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      'Member ID',
                      profileId.isEmpty ? '—' : profileId,
                    ),
                    _buildDivider(context),
                    _buildInfoRow(context, 'Role', _roleLabel(role)),
                    _buildDivider(context),
                    _buildInfoRow(
                      context,
                      'Status',
                      status == 'active' ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── App Info Card ──
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(context, 'Version', '1.0.0'),
                    _buildDivider(context),
                    _buildInfoRow(context, 'Made by', 'dbaCoders'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Logout Button ──
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _confirmLogout(context, viewModel),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Footer ──
              Center(
                child: Text(
                  'Made with ❤️ by dbaCoders',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: one row of the info card ──
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryOf(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }

  // ── Helper: thin divider between rows ──
  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark
            ? AppColors.darkDivider
            : Colors.black.withValues(alpha: 0.06),
      ),
    );
  }

  // ── Helper: human-readable role label ──
  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'receptionist':
        return 'Receptionist';
      case 'trainer':
        return 'Trainer';
      case 'member':
        return 'Member';
      default:
        return role;
    }
  }

  // ── Logout confirmation dialog ──
  void _confirmLogout(BuildContext context, dynamic viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                viewModel.logout();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
