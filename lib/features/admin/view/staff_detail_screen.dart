import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../staff/model/staff_model.dart';
import '../../staff/repository/staff_repository.dart';

/// Detail screen for a single staff member with contact & account info and status toggling.
class StaffDetailScreen extends StatefulWidget {
  final StaffModel staff;

  const StaffDetailScreen({super.key, required this.staff});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late StaffModel _staff;
  bool _isTogglingStatus = false;

  @override
  void initState() {
    super.initState();
    _staff = widget.staff;
  }

  /// Handles staff deactivation/reactivation confirmation and status update.
  Future<void> _handleToggleStatus() async {
    final willDeactivate = _staff.isActive;
    final actionWord = willDeactivate ? 'Deactivate' : 'Reactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E281E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          title: Text(
            '$actionWord staff member?',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            willDeactivate
                ? '${_staff.name} will not be able to log in until reactivated.'
                : '${_staff.name} will regain access to their account.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                actionWord,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: willDeactivate ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isTogglingStatus = true);

    try {
      final newStatus = willDeactivate ? 'inactive' : 'active';
      final repo = StaffRepository();
      final success = await repo.updateStaffStatus(
        uid: _staff.uid,
        status: newStatus,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _staff = StaffModel(
            uid: _staff.uid,
            profileId: _staff.profileId,
            name: _staff.name,
            role: _staff.role,
            status: newStatus,
            phone: _staff.phone,
            email: _staff.email,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_staff.name} is now $newStatus.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $actionWord staff. Please try again.'),
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
        setState(() => _isTogglingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Staff Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: Avatar + Name + Role Badge ──
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
                            _staff.name.isNotEmpty
                                ? _staff.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _staff.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _staff.profileId.isNotEmpty
                            ? '${_staff.roleLabel} • ${_staff.profileId}'
                            : _staff.roleLabel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
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
                    _StaffInfoRow(
                      label: 'Email',
                      value: _staff.email.isEmpty ? '—' : _staff.email,
                    ),
                    _StaffInfoRow(
                      label: 'Phone',
                      value: _staff.phone.isEmpty ? '—' : _staff.phone,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Account Info Card ──
                _buildSectionCard(
                  title: 'Account Details',
                  icon: Icons.badge_outlined,
                  rows: [
                    _StaffInfoRow(
                      label: 'Role',
                      value: _staff.roleLabel,
                    ),
                    _StaffInfoRow(
                      label: 'Profile ID',
                      value: _staff.profileId.isEmpty ? '—' : _staff.profileId,
                    ),
                    _StaffInfoRow(
                      label: 'Status',
                      value: _staff.isActive ? 'Active' : 'Inactive',
                      valueColor: _staff.isActive
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),

                // ── Deactivate / Reactivate Button (non-admin only) ──
                if (!_staff.isAdmin) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isTogglingStatus ? null : _handleToggleStatus,
                      icon: _isTogglingStatus
                          ? const SizedBox.shrink()
                          : Icon(
                              _staff.isActive
                                  ? Icons.person_off_outlined
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: _staff.isActive
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                      label: _isTogglingStatus
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: _staff.isActive
                                  ? AppColors.error
                                  : AppColors.primary,
                              ),
                            )
                          : Text(
                              _staff.isActive
                                  ? 'Deactivate Staff Member'
                                  : 'Reactivate Staff Member',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _staff.isActive
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _staff.isActive
                            ? AppColors.error
                            : AppColors.primary,
                        side: BorderSide(
                          color: (_staff.isActive
                                  ? AppColors.error
                                  : AppColors.primary)
                              .withValues(alpha: 0.5),
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
      ),
    );
  }

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
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        );
      }
    }

    return GlassCard(
      useBlur: false,
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _StaffInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StaffInfoRow({
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.6),
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
              color: valueColor ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

