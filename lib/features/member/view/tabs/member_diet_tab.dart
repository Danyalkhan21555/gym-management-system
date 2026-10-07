import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Member Diet Plan Tab placeholder skeleton.
class MemberDietTab extends StatelessWidget {
  const MemberDietTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Diet Plan — Coming Soon',
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
