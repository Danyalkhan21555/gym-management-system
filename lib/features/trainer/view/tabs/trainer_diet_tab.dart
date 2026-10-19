import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../dietPlan/viewmodel/diet_plan_viewmodel.dart';
import '../../../member/viewModel/view_model.dart';

/// Trainer Diet Plans tab allowing trainers to view, create, and update
/// diet plans for active members.
class TrainerDietTab extends StatefulWidget {
  const TrainerDietTab({super.key});

  @override
  State<TrainerDietTab> createState() => _TrainerDietTabState();
}

class _TrainerDietTabState extends State<TrainerDietTab> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String? _selectedMemberId;
  String? _selectedMemberName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MemberViewModel>().loadMembers();
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onMemberSelected(String? memberId) {
    if (memberId == null) return;
    if (memberId == _selectedMemberId) return;

    final memberVm = context.read<MemberViewModel>();
    final member = memberVm.allMembers.firstWhere(
      (m) => m.uid == memberId,
      orElse: () => memberVm.allMembers.first, // Fallback safety
    );

    // Clear old plan UI
    context.read<DietPlanViewModel>().clearPlan();

    setState(() {
      _selectedMemberId = memberId;
      _selectedMemberName = member.name;
      _contentController.clear();
    });

    // Load existing plan for this member (if any)
    _loadMemberPlan(memberId);
  }

  Future<void> _loadMemberPlan(String memberId) async {
    final planVm = context.read<DietPlanViewModel>();
    await planVm.loadPlan(memberId);

    if (!mounted) return;

    // Prefill the text field with existing content
    final plan = planVm.currentPlan;
    if (plan != null) {
      _contentController.text = plan.content;
    }
  }

  Future<void> _savePlan(dynamic authVm) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) return;

    final planVm = context.read<DietPlanViewModel>();

    final authUser = authVm.userProfile;
    if (authUser == null) return;

    final success = await planVm.savePlan(
      memberId: _selectedMemberId!,
      memberName: _selectedMemberName ?? '',
      trainerId: authUser.uid,
      trainerName: authUser.name,
      content: _contentController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Diet plan saved for $_selectedMemberName.'
              : planVm.errorMessage ?? 'Failed to save.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: success ? AppColors.dark : AppColors.error,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final memberVm = context.watch<MemberViewModel>();
    final planVm = context.watch<DietPlanViewModel>();
    final authVm = AuthProvider.of(context);

    // Filter to only active members
    final activeMembers = memberVm.members
        .where((m) => m.isActive)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                const Text(
                  'Diet Plans',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Write or update a member\'s diet plan.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Member Dropdown ──
                if (memberVm.isLoading)
                  GlassCard(
                    height: 60,
                    padding: EdgeInsets.zero,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                else if (activeMembers.isEmpty)
                  GlassCard(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 32,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No active members',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add members from the receptionist dashboard first.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMemberId,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    dropdownColor: const Color(0xFF1A2A1A),
                    borderRadius: BorderRadius.circular(16),
                    iconEnabledColor: Colors.white.withValues(alpha: 0.6),
                    decoration: InputDecoration(
                      labelText: 'Select Member',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    items: activeMembers
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.uid,
                            child: Text(
                              '${m.name} (${m.memberId})',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _onMemberSelected,
                  ),

                const SizedBox(height: 20),

                // ── Diet Plan Text Field (only if member selected) ──
                if (_selectedMemberId != null) ...[
                  if (planVm.isLoading)
                    GlassCard(
                      height: 200,
                      padding: EdgeInsets.zero,
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    TextFormField(
                      controller: _contentController,
                      maxLines: 10,
                      minLines: 8,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Breakfast: 4 eggs, 2 slices brown bread...'
                            '\n\nLunch: Grilled chicken with rice...'
                            '\n\nDinner: ...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please write a diet plan';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),

                  // Hint text showing creation info
                  if (planVm.hasPlan && planVm.currentPlan != null)
                    Text(
                      'Last updated: ${_formatDate(planVm.currentPlan!.updatedAt)} '
                      'by ${planVm.currentPlan!.trainerName}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Error box ──
                  if (planVm.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              planVm.errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Save Button ──
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          planVm.isSaving ? null : () => _savePlan(authVm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.dark,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: planVm.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.dark,
                              ),
                            )
                          : Text(
                              planVm.hasPlan
                                  ? 'Update Diet Plan'
                                  : 'Save Diet Plan',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
