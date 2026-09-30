import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/authentication/repository/auth_repository.dart';
import 'features/authentication/repository/profile_repository.dart';
import 'features/authentication/viewModel/auth_viewmodel.dart';
import 'features/authentication/view/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            AuthRepository(),
            ProfileRepository(),
          )..checkCurrentUser(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gym Management System',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
