import 'package:flutter/material.dart';
import 'package:chatapp/feature/home/app_main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    _initializeSession();
    super.initState();
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
      ]); // future.delayed

      if (mounted) {
        setState(() {
          _isInitialized = true; // move to home screen after init
        });
      }
    } catch (e) {
      print("Error initializing session: $e"); // Don't invoke 'print' in production code. Try using a logger
      if (mounted) {
        // still alive moving forward even if init fails
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
          ), // Column
        ), // Center
      ); // Scaffold
    }
    // once initialized -> go to main app home screen
    return const MainHomeScreen();
  }
}