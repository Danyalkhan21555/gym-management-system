import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/member_model.dart';

/// Read-only detail screen for a single member.
/// Displayed when an admin taps on a member in the members list.
class MemberDetailScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Member Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header: Avatar + Name + MemberId ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.initial,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      member.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.memberId,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Contact Info Card ──
              _buildSectionCard(
                title: 'Contact Info',
                icon: Icons.phone_outlined,
                rows: [
                  _InfoRow(
                    label: 'Phone',
                    value: member.phone.isEmpty ? '—' : member.phone,
                  ),
                  _InfoRow(
                    label: 'Email',
                    value: member.email.isEmpty ? '—' : member.email,
                  ),
                  _InfoRow(
                    label: 'Address',
                    value: member.address.isEmpty ? '—' : member.address,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Personal Info Card ──
              _buildSectionCard(
                title: 'Personal Info',
                icon: Icons.person_outline,
                rows: [
                  _InfoRow(
                    label: 'Gender',
                    value: member.gender.isEmpty ? '—' : member.genderLabel,
                  ),
                  _InfoRow(
                    label: 'Joined',
                    value: _formatDate(member.createdAt),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Status Card ──
              _buildSectionCard(
                title: 'Membership Status',
                icon: Icons.verified_outlined,
                rows: [
                  _InfoRow(
                    label: 'Status',
                    value: member.statusLabel,
                    valueColor: _statusColor(member.status),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a rounded section card matching the admin_profile_tab design
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> rows,
  }) {
    final List<Widget> children = [];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// Formats DateTime into "D Mon YYYY" string format (e.g. 15 Jan 2025)
  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  /// Converts month index to abbreviated month name
  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  /// Determines status label color
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.dark;
      case 'inactive':
        return Colors.grey[700] ?? Colors.grey;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.dark;
    }
  }
}

/// Helper row for displaying key-value information pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.dark,
            ),
          ),
        ),
      ],
    );
  }
}
