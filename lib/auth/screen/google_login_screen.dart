import 'package:flutter/material.dart';
import 'package:chatapp/chat/utils/utils.dart';
import 'package:chatapp/auth/service/google_auth_service.dart'; // using AuthMethod now

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _isLoading = false;

  // Define your custom colors (edit if you already have these)
  final Color bodyColor = Colors.white;
  final Color appBarColor = const Color(0xFFF5F5F5);

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call AuthMethod's sign-in
      final userCredential = await AuthMethod().signInWithGoogle(/*context*/);

      if (!mounted) return;

      if (userCredential != null && userCredential.user != null) {
        print('✅ User signed in: ${userCredential.user?.displayName}');
        // Navigate to your home or chat screen
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;

      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: 'Google Login failed. Try again!',
      );
      print('Google sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bodyColor,
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              "assets/cover_image.jpg",
              height: size.height * 0.56,
              fit: BoxFit.cover,
            ),
            SizedBox(height: size.height * 0.13),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appBarColor,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
