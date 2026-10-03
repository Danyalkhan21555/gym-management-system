import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../model/member_model.dart';
import '../repository/member_repository.dart';

/// Detail screen for a single member with membership info and deactivation option.
class MemberDetailScreen extends StatefulWidget {
  final MemberModel member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  bool _isRemoving = false;

  /// Handles member deactivation confirmation and status update.
  Future<void> _handleRemoveMember() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Remove member?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          content: Text(
            '${widget.member.name} will no longer be able to log in. You can reactivate them later.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isRemoving = true);

    try {
      final repo = MemberRepository();
      final success = await repo.updateMemberStatus(
        uid: widget.member.uid,
        status: 'inactive',
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.member.name} has been deactivated.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to deactivate member. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRemoving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

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

              // ── Membership Details Card ──
              _buildSectionCard(
                title: 'Membership Details',
                icon: Icons.card_membership_outlined,
                rows: [
                  _InfoRow(
                    label: 'Plan',
                    value: member.planLabel,
                  ),
                  _InfoRow(
                    label: 'Duration',
                    value: member.durationLabel,
                  ),
                  _InfoRow(
                    label: 'Started',
                    value: member.startDate != null
                        ? _formatDate(member.startDate!)
                        : '—',
                  ),
                  _InfoRow(
                    label: 'Expires',
                    value: member.expiryDate != null
                        ? _formatDate(member.expiryDate!)
                        : '—',
                  ),
                  _InfoRow(
                    label: 'Days Left',
                    value: member.expiryDate == null
                        ? '—'
                        : member.daysRemaining > 0
                            ? '${member.daysRemaining} ${member.daysRemaining == 1 ? 'day' : 'days'}'
                            : 'Expired',
                    valueColor: member.expiryDate == null
                        ? null
                        : member.daysRemaining > 0
                            ? const Color(0xFF2E7D32)
                            : AppColors.error,
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

              // ── Remove / Deactivate Member Button ──
              if (member.status.toLowerCase() != 'inactive') ...[
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _isRemoving ? null : _handleRemoveMember,
                    icon: _isRemoving
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.person_remove_outlined,
                            size: 20,
                            color: AppColors.error,
                          ),
                    label: _isRemoving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.error,
                            ),
                          )
                        : const Text(
                            'Remove Member',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],

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
