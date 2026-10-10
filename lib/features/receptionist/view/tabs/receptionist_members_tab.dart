import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../member/model/member_model.dart';
import '../../../member/view/member_detail_screen.dart';
// Fix case-sensitivity and directory depth for MemberViewModel import
import '../../../member/viewModel/view_model.dart';

class ReceptionistMembersTab extends StatefulWidget {
  const ReceptionistMembersTab({super.key});

  @override
  State<ReceptionistMembersTab> createState() => _ReceptionistMembersTabState();
}

class _ReceptionistMembersTabState extends State<ReceptionistMembersTab> {
  @override
  void initState() {
    super.initState();
    // Load members after first frame render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberViewModel>().loadMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemberViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar + count header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.members.length} members',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (q) =>
                        context.read<MemberViewModel>().searchMembers(q),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.dark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or phone',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            // ── List area ──────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<MemberViewModel>().loadMembers();
                },
                color: AppColors.primary,
                child: _buildList(context, viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list area handling loading, error, empty, and data states
  Widget _buildList(BuildContext context, MemberViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error state with retry
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<MemberViewModel>().loadMembers(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (viewModel.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No members yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Members added by receptionist will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Members list
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      itemCount: viewModel.members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _MemberListItem(member: viewModel.members[index]);
      },
    );
  }
}

// ── Member card widget ────────────────────────────────────────────────────────

class _MemberListItem extends StatelessWidget {
  final MemberModel member;

  const _MemberListItem({required this.member});

  /// Status background color helper
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primary;
      case 'inactive':
        return Colors.grey;
      case 'expired':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  /// Status text color helper
  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.dark;
      case 'inactive':
        return Colors.grey[700] ?? Colors.grey;
      case 'expired':
        return AppColors.error;
      default:
        return Colors.grey[700] ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberDetailScreen(member: member),
              ),
            );
            if (context.mounted) {
              context.read<MemberViewModel>().loadMembers();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member.initial,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name + memberId + phone + status badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${member.memberId} • ${member.phone}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            member.status,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          member.statusLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusTextColor(member.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ── 3-dot action menu ──
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onSelected: (value) {
                    if (value == 'view') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(member: member),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<MemberViewModel>().loadMembers();
                        }
                      });
                    } else if (value == 'remove') {
                      _confirmRemoveMember(context, member);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 18, color: AppColors.dark),
                          SizedBox(width: 10),
                          Text(
                            'View details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 10),
                          Text(
                            'Remove permanently',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Displays confirmation dialog and permanently deletes member document.
  Future<void> _confirmRemoveMember(
    BuildContext context,
    MemberModel member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Remove member permanently?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${member.name} will be permanently removed. This cannot be undone. They will no longer be able to log in.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Consider deactivating instead if you might reactivate later.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final vm = context.read<MemberViewModel>();
    final success = await vm.deleteMember(member.uid);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${member.name} has been removed.'
              : vm.errorMessage ?? 'Failed to remove.',
        ),
        backgroundColor: success ? AppColors.dark : AppColors.error,
      ),
    );
  }
}
