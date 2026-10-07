import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Member Home Tab placeholder skeleton.
class MemberHomeTab extends StatelessWidget {
  const MemberHomeTab({super.key});

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
