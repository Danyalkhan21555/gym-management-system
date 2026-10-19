import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../staff/model/staff_model.dart';
import '../../../staff/view/create_staff_screen.dart';
import '../../../staff/viewmodel/staff_viewmodel.dart';

class AdminStaffTab extends StatefulWidget {
  const AdminStaffTab({super.key});

  @override
  State<AdminStaffTab> createState() => _AdminStaffTabState();
}

class _AdminStaffTabState extends State<AdminStaffTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffViewModel>().loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StaffViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateStaff,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.dark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 26),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + search bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Staff',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.staff.length} members',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (q) =>
                        context.read<StaffViewModel>().searchStaff(q),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or role',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            // ── List area ──────────────────────────────────────────────────
            Expanded(child: _buildList(viewModel)),
          ],
        ),
      ),
    );
  }

  /// Pushes [CreateStaffScreen] and refreshes the list on return.
  Future<void> _openCreateStaff() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateStaffScreen(),
      ),
    );
    // Reload staff list after returning
    if (mounted) {
      context.read<StaffViewModel>().loadStaff();
    }
  }

  Widget _buildList(StaffViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error state
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<StaffViewModel>().loadStaff(),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 40,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'No staff found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Staff list
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: viewModel.staff.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _StaffListItem(staff: viewModel.staff[index]);
      },
    );
  }
}

// ── Staff card ─────────────────────────────────────────────────────────────────

class _StaffListItem extends StatelessWidget {
  final StaffModel staff;

  const _StaffListItem({required this.staff});

  @override
  Widget build(BuildContext context) {
    // Get current logged-in admin UID to prevent self-deactivation
    final currentAdminUid = AuthProvider.of(context).userProfile?.uid;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          // ── Avatar circle ──
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                staff.name.isNotEmpty
                    ? staff.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ── Name / role / status ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${staff.roleLabel} • ${staff.profileId}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: staff.isActive
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    staff.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: staff.isActive
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Deactivate / Activate / Remove action menu ──
          if (staff.uid != currentAdminUid)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.6)),
              onSelected: (value) {
                if (value == 'deactivate') {
                  _confirmStatusChange(context, staff, 'inactive');
                } else if (value == 'activate') {
                  _confirmStatusChange(context, staff, 'active');
                } else if (value == 'remove') {
                  _confirmRemove(context, staff);
                }
              },
              itemBuilder: (context) => [
                if (staff.isActive)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text(
                          'Deactivate',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!staff.isActive)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Activate',
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
            )
          else
            const SizedBox(width: 24), // Keep layout spacing consistent
        ],
      ),
    );
  }

  /// Displays confirmation dialog and updates staff status in Firestore.
  Future<void> _confirmStatusChange(
    BuildContext context,
    StaffModel staff,
    String newStatus,
  ) async {
    final isDeactivating = newStatus == 'inactive';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isDeactivating ? 'Deactivate staff?' : 'Activate staff?',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          isDeactivating
              ? '${staff.name} will no longer be able to log in. You can reactivate them later.'
              : '${staff.name} will be able to log in again.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
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
            style: TextButton.styleFrom(
              foregroundColor: isDeactivating
                  ? AppColors.error
                  : AppColors.primary,
            ),
            child: Text(
              isDeactivating ? 'Deactivate' : 'Activate',
              style: const TextStyle(
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

    final vm = context.read<StaffViewModel>();
    final success = await vm.updateStaffStatus(
      uid: staff.uid,
      status: newStatus,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDeactivating
                ? '${staff.name} has been deactivated.'
                : '${staff.name} has been activated.',
          ),
          backgroundColor: AppColors.dark,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to update.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Displays confirmation dialog and permanently deletes staff document.
  Future<void> _confirmRemove(BuildContext context, StaffModel staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Remove staff permanently?',
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
              '${staff.name} will be permanently removed. This cannot be undone. They will no longer be able to log in.',
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

    final vm = context.read<StaffViewModel>();
    final success = await vm.deleteStaff(staff.uid);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${staff.name} has been removed.'
              : vm.errorMessage ?? 'Failed to remove.',
        ),
        backgroundColor: success ? AppColors.dark : AppColors.error,
      ),
    );
  }
}

