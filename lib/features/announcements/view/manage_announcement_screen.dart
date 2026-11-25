import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../viewmodel/announcement_viewmodel.dart';
import '../repository/announcement_repository.dart';

class ManageAnnouncementScreen extends StatefulWidget {
  final String adminUid;
  final String adminName;

  const ManageAnnouncementScreen({
    super.key,
    required this.adminUid,
    required this.adminName,
  });

  @override
  State<ManageAnnouncementScreen> createState() => _ManageAnnouncementScreenState();
}

class _ManageAnnouncementScreenState extends State<ManageAnnouncementScreen> {
  late final AnnouncementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Create a self-contained ViewModel for this screen
    _viewModel = AnnouncementViewModel(AnnouncementRepository());
    _viewModel.loadAnnouncement();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AnnouncementViewModel>.value(
      value: _viewModel,
      child: _ManageAnnouncementContent(
        adminUid: widget.adminUid,
        adminName: widget.adminName,
      ),
    );
  }
}

class _ManageAnnouncementContent extends StatefulWidget {
  final String adminUid;
  final String adminName;

  const _ManageAnnouncementContent({
    required this.adminUid,
    required this.adminName,
  });

  @override
  State<_ManageAnnouncementContent> createState() => _ManageAnnouncementContentState();
}

class _ManageAnnouncementContentState extends State<_ManageAnnouncementContent> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveAnnouncement() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    final viewModel = context.read<AnnouncementViewModel>();

    final success = await viewModel.saveAnnouncement(
      content: _contentController.text,
      adminUid: widget.adminUid,
      adminName: widget.adminName,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement saved')),
      );
    }
  }

  void _deleteAnnouncement() {
    final viewModel = context.read<AnnouncementViewModel>();
    showDialog(
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
          title: const Text(
            'Delete announcement?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            'This cannot be undone.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
              onPressed: () async {
                Navigator.pop(dialogContext); // close dialog
                final success = await viewModel.deleteAnnouncement();
                if (!mounted) return;
                if (success) {
                  Navigator.pop(context); // close manage screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Announcement deleted')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnnouncementViewModel>();

    // Safely prefill the text field when data loads without overwriting user input
    if (_contentController.text.isEmpty && viewModel.hasAnnouncement) {
      _contentController.text = viewModel.announcement!.content;
    }

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Manage Announcement',
            style: TextStyle(
              fontFamily: 'Poppins',
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
            child: GlassCard(
              useBlur: false,
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write today\'s announcement',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This will be visible to all staff and members.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    minLines: 6,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Gym will remain closed tomorrow...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white70,
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
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.errorMessage != null) ...[
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
                              viewModel.errorMessage!,
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isSaving ? null : _saveAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.dark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: viewModel.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.dark,
                              ),
                            )
                          : const Text(
                              'Save Announcement',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.hasAnnouncement)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed:
                            viewModel.isSaving ? null : _deleteAnnouncement,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Delete Announcement'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
