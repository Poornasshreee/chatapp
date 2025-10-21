import 'package:flutter/material.dart';
import 'package:chatapp/auth/screen/user_login_screen.dart';
import 'package:chatapp/auth/service/auth_provider.dart';
import 'package:chatapp/auth/service/auth_service.dart';
import 'package:chatapp/chat/utils/utils.dart';
import 'package:chatapp/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    void signup() async {
      formNotifier.setLoading(true);
      final res = await authMethod.signUpUser(
        email: formState.email,
        password: formState.password,
        name: formState.name,
      );
      formNotifier.setLoading(false);

      if (res == "success" && context.mounted) {
        NavigationHelper.pushReplacement(context, UserLoginScreen());
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Sign Up Successful. Now turn to login",
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

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              height: height / 2.4,
              width: double.maxFinite,
              decoration: const BoxDecoration(),
              child: Image.asset("assets/77881.jpg", fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    autocorrect: false,
                    onChanged: (value) => formNotifier.updateName(value),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: "Enter your name",
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(15),
                      errorText: formState.nameError,
                    ),
                  ),
                  const SizedBox(height: 15),
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
                        onPressed: () =>
                            formNotifier.togglePasswordVisibility(),
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
        onPressed: formState.isFormValid ? signup : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: formState.isFormValid ? Colors.blue : Colors.grey,
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Spacer(),
                      const Text("Already have an account?"),
                      GestureDetector(
                        onTap: () {
                          NavigationHelper.push(context, UserLoginScreen());
                        },
                        child: const Text(
                          "Login",
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
