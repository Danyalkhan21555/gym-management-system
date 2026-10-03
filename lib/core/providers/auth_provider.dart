import 'package:flutter/material.dart';
import '../../features/authentication/viewModel/auth_viewmodel.dart';

/// Custom InheritedNotifier that exposes AuthViewModel to the 
/// entire widget tree — including Scaffold bodies, Navigator 
/// routes, and nested subtrees that the Provider package fails 
/// to reach in certain Flutter versions.
class AuthProvider extends InheritedNotifier<AuthViewModel> {
  const AuthProvider({
    super.key,
    required AuthViewModel viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  static AuthViewModel of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null,
        'AuthProvider not found. Make sure it is placed above '
        'MaterialApp in main.dart.');
    return provider!.notifier!;
  }
}
