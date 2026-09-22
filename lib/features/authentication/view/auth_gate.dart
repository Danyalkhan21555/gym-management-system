import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/view/admin_dashboard_screen.dart';
import '../repository/auth_repository.dart';
import '../repository/profile_repository.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AuthViewModel(AuthRepository(), ProfileRepository())
            ..checkCurrentUser(),
      child: const _AuthGateContent(),
    );
  }
}

class _AuthGateContent extends StatelessWidget {
  const _AuthGateContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        panel = const Center(child: Text('Receptionist Panel'));
        break;
      case 'trainer':
        panel = const Center(child: Text('Trainer Panel'));
        break;
      case 'member':
        panel = const Center(child: Text('Member Panel'));
        break;
      default:
        panel = const Center(child: Text('Unknown user role'));
    }

    return Scaffold(body: panel);
  }
}
