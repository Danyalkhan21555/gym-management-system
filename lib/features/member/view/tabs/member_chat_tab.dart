import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/repository/chat_repository.dart';
import '../../../chat/view/chat_screen.dart';
import '../../../staff/model/staff_model.dart';
import '../../../staff/viewmodel/staff_viewmodel.dart';

/// Member Chat Tab — shows a list of trainers to chat with.
class MemberChatTab extends StatefulWidget {
  const MemberChatTab({super.key});

  @override
  State<MemberChatTab> createState() => _MemberChatTabState();
}

class _MemberChatTabState extends State<MemberChatTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reuse StaffViewModel to fetch the staff list.
      // It fetches all staff, we'll filter to trainers only.
      context.read<StaffViewModel>().loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = AuthProvider.of(context);
    final staffVm = context.watch<StaffViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter to active trainers only
    final trainers = staffVm.staff
        .where((s) => s.role == 'trainer' && s.isActive)
        .toList();

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
                    'Chat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trainers.length} trainers available',
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

            // ── List ──
            Expanded(
              child: staffVm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : trainers.isEmpty
                      ? _buildEmpty(context)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          itemCount: trainers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final trainer = trainers[index];
                            return _TrainerChatTile(
                              trainer: trainer,
                              onTap: () => _openChat(context, trainer, authVm),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No trainers available',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Trainers will appear here once added by the admin.',
              textAlign: TextAlign.center,
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
    );
  }

  /// Opens a chat with the selected trainer.
  Future<void> _openChat(
    BuildContext context,
    StaffModel trainer,
    dynamic authVm,
  ) async {
    final memberProfile = authVm.userProfile;
    if (memberProfile == null) return;

    // Create or fetch the conversation between this member and the trainer
    final repo = ChatRepository();
    final conversation = await repo.getOrCreateConversation(
      user1Id: memberProfile.uid,
      user1Name: memberProfile.name,
      user1Role: 'member',
      user2Id: trainer.uid,
      user2Name: trainer.name,
      user2Role: 'trainer',
    );

    if (conversation == null) return;
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: conversation.roomId,
          otherUserId: trainer.uid,
          otherUserName: trainer.name,
          otherUserRole: 'Trainer',
        ),
      ),
    );
  }
}

// ── Trainer card widget ──
class _TrainerChatTile extends StatelessWidget {
  final StaffModel trainer;
  final VoidCallback onTap;

  const _TrainerChatTile({
    required this.trainer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      trainer.name.isNotEmpty
                          ? trainer.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.primary : AppColors.dark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Trainer • ${trainer.profileId}',
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
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}