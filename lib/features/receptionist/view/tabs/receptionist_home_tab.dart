import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder tab for Receptionist Home.
class ReceptionistHomeTab extends StatelessWidget {
  const ReceptionistHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Home — Coming Soon',
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
