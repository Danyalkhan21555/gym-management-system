import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder tab for Trainer Diet Plans view.
class TrainerDietTab extends StatelessWidget {
  const TrainerDietTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Diet Plans — Coming Soon',
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
