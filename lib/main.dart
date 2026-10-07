import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthViewModel _authViewModel;
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(AuthRepository(), ProfileRepository())
      ..checkCurrentUser();

    _themeProvider = ThemeProvider()..loadTheme();
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider.value(value: _authViewModel),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return AuthProvider(
            viewModel: _authViewModel,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Gym Management System',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.themeMode,
              home: const AuthGate(),
            ),
          );
        },
      ),
    );
  }
}
