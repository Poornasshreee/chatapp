import 'package:flutter/material.dart';
import 'package:chatapp/auth/screen/google_login_screen.dart';
import 'package:chatapp/auth/screen/signup_screen.dart';
import 'package:chatapp/auth/service/auth_provider.dart';
import 'package:chatapp/auth/service/auth_service.dart';
import 'package:chatapp/chat/screens/app_home_screen.dart';
import 'package:chatapp/chat/utils/utils.dart';
import 'package:chatapp/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserLoginScreen extends ConsumerWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    void login() async {
      formNotifier.setLoading(true);
      final res = await authMethod.loginUser(
        email: formState.email,
        password: formState.password,
      );
      formNotifier.setLoading(false);

      if (res == "success" && context.mounted) {
        NavigationHelper.pushReplacement(context, MainHomeScreen());
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Successful Login",
        );
      } else {
        if (context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: res,
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 2.1,
              width: double.maxFinite,
              child: Image.asset("assets/2752392.jpg", fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    autocorrect: false,
                    onChanged: (value) => formNotifier.updateEmail(value),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Enter your email",
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(15),
                      errorText: formState.emailError,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    autocorrect: false,
                    onChanged: (value) => formNotifier.updatePassword(value),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: formState.isPasswordHidden,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Enter your password",
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(15),
                      errorText: formState.passwordError,
                      suffixIcon: IconButton(
                        onPressed: () => formNotifier.togglePasswordVisibility(),
                        icon: Icon(
                          formState.isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  formState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: formState.isFormValid ? login : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: formState.isFormValid
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.black26)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("or"),
                      ),
                      Expanded(child: Divider(color: Colors.black26)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Google Auth Button
                  const GoogleLoginScreen(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Spacer(),
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          NavigationHelper.push(context, const SignupScreen());
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
