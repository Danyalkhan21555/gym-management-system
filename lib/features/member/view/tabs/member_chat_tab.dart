import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../chat/repository/chat_repository.dart';
import '../../../chat/view/chat_screen.dart';
import '../../../chat/model/conversation_model.dart';
import '../../../chat/viewmodel/chat_viewmodel.dart';
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
                  const Text(
                    'Chat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trainers.length} trainers available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ──
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.darkSurface,
                onRefresh: () async {
                  await context.read<StaffViewModel>().loadStaff();
                },
                child: staffVm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : trainers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                              _buildEmpty(),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                            itemCount: trainers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final trainer = trainers[index];
                              final currentUserId =
                                  authVm.userProfile?.uid ?? '';
                              return _TrainerChatTile(
                                trainer: trainer,
                                currentUserId: currentUserId,
                                onTap: () =>
                                    _openChat(context, trainer, authVm),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'No trainers available',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Trainers will appear here once added by the admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
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

    final roomId = conversation.roomId;
    context.read<ChatViewModel>().markRoomAsRead(roomId);

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

// ── Trainer card widget with real-time unread badge ──
class _TrainerChatTile extends StatelessWidget {
  final StaffModel trainer;
  final String currentUserId;
  final VoidCallback onTap;

  const _TrainerChatTile({
    required this.trainer,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final roomId = ConversationModel.generateRoomId(currentUserId, trainer.uid);
    final chatVm = context.watch<ChatViewModel>();

    return StreamBuilder<ConversationModel?>(
      stream: ChatRepository().watchConversation(roomId),
      builder: (context, snapshot) {
        final conv = snapshot.data;
        final isUnread = chatVm.isRoomUnread(conv, currentUserId);

        return GlassCard(
          useBlur: false,
          padding: EdgeInsets.zero,
          borderRadius: 20,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trainer.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv?.lastMessageAt != null)
                            Text(
                              _formatTime(conv!.lastMessageAt!),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: isUnread
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.4),
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv != null && conv.lastMessage.isNotEmpty
                                  ? conv.lastMessage
                                  : 'Trainer • ${trainer.profileId}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isUnread
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}