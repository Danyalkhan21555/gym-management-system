import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder tab for Receptionist Members list.
class ReceptionistMembersTab extends StatelessWidget {
  const ReceptionistMembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Members — Coming Soon',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ),
      ),
    );
  }
}
