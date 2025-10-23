import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatapp/chat/screens/app_home_screen.dart';

// ----------------- Placeholder for app state manager provider -----------------
final appStateManagerProvider = Provider<AppStateManager>((ref) {
  return AppStateManager();
});

class AppStateManager {
  Future<void> initializeUserSession() async {
    // simulate a session initialization delay
    await Future.delayed(const Duration(seconds: 2));
  }
}

// MainHomeScreen is now imported from chat/screens/app_home_screen.dart

// ----------------- Authentication Wrapper -----------------
class AuthenticationWrapper extends ConsumerStatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  ConsumerState<AuthenticationWrapper> createState() =>
      _AuthenticationWrapperState();
}

class _AuthenticationWrapperState
    extends ConsumerState<AuthenticationWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    try {
      final appManager = ref.read(appStateManagerProvider);
      // Run session initialization with timeout (max 10s)
      await Future.any([
        appManager.initializeUserSession(),
        Future.delayed(
          const Duration(seconds: 10),
          () => throw TimeoutException('Session init timed out'),
        ),
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true; // move to home screen after init
        });
      }
    } catch (e) {
      debugPrint("Error initializing session: $e");
      if (mounted) {
        setState(() {
          _isInitialized = true; // prevent infinite loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // show loader until user session is initialized
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Setting up your account..."),
            ],
          ),
        ),
      );
    }

    // once initialized -> go to main app home screen
    return const MainHomeScreen();
  }
}

// ----------------- Main App Entry Point -----------------
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Wrapper Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}
