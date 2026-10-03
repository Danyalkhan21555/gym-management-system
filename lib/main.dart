import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/repository/auth_repository.dart';
import 'features/authentication/repository/profile_repository.dart';
import 'features/authentication/viewModel/auth_viewmodel.dart';
import 'features/authentication/view/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(
      AuthRepository(),
      ProfileRepository(),
    )..checkCurrentUser();
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      viewModel: _authViewModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gym Management System',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
