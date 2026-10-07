import 'package:flutter/material.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../admin/view/admin_dashboard_screen.dart';
import '../../member/view/member_dashboard_screen.dart';
import '../../receptionist/view/receptionist_dashboard_screen.dart';
import '../../trainer/view/trainer_dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthGateContent();
  }
}

class _AuthGateContent extends StatelessWidget {
  const _AuthGateContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthProvider.of(context);

    if (!viewModel.hasCheckedCurrentUser) {
      return const _SplashScreen();
    }

    if (viewModel.currentUser == null) {
      return const LoginScreen();
    }

    if (viewModel.userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    final role = viewModel.userProfile!.role;
    Widget panel;

    switch (role) {
      case 'admin':
        panel = const AdminDashboardScreen();
        break;
      case 'receptionist':
        panel = const ReceptionistDashboardScreen();
        break;
      case 'trainer':
        panel = const TrainerDashboardScreen();
        break;
      case 'member':
        panel = const MemberDashboardScreen();
        break;
      default:
        panel = const Center(child: Text('Unknown user role'));
    }

    return Scaffold(body: panel);
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Gym Management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
