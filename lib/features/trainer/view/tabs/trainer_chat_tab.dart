import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../chat/repository/chat_repository.dart';
import '../../../chat/view/chat_screen.dart';
import '../../../member/model/member_model.dart';
import '../../../member/viewModel/view_model.dart';

/// Trainer Chat tab listing all active members for 1-on-1 messaging.
class TrainerChatTab extends StatefulWidget {
  const TrainerChatTab({super.key});

  @override
  State<TrainerChatTab> createState() => _TrainerChatTabState();
}

class _TrainerChatTabState extends State<TrainerChatTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MemberViewModel>().loadMembers();
      }
    });
  }

  Future<void> _openChat(MemberModel member) async {
    final authVm = AuthProvider.of(context);
    final trainerProfile = authVm.userProfile;
    if (trainerProfile == null) return;

    final repo = ChatRepository();
    final conversation = await repo.getOrCreateConversation(
      user1Id: trainerProfile.uid,
      user1Name: trainerProfile.name,
      user1Role: 'trainer',
      user2Id: member.uid,
      user2Name: member.name,
      user2Role: 'member',
    );

    if (conversation == null) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: conversation.roomId,
          otherUserId: member.uid,
          otherUserName: member.name,
          otherUserRole: 'Member',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberVm = context.watch<MemberViewModel>();

    // Filter to active members only
    final activeMembers =
        memberVm.members.where((m) => m.isActive).toList();

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
                    '${activeMembers.length} members',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Member List ──
            Expanded(
              child: memberVm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : activeMembers.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: activeMembers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = activeMembers[index];
                            return _MemberChatTile(
                              member: member,
                              onTap: () => _openChat(member),
                            );
                          },
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
                Icons.people_outline,
                size: 48,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'No active members',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Active members will appear here for messaging.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Member list tile displaying avatar initial, member name, and member ID.
class _MemberChatTile extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onTap;

  const _MemberChatTile({
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with first letter
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
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.memberId,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
