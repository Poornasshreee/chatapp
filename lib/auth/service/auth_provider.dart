/*import 'package:chatapp/auth/model/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(AuthFormState());
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordHidden: !state.isPasswordHidden);
  }
  void updateName(String name) {
    String? nameError;
    if (name.isNotEmpty && name.length < 6) {
      nameError = "Provide your full name";
    }
    state = state.copyWith(name: name, nameError: nameError);
  }
  /*void updateEmail(String email) {
    String? emailError;
    if (email.isNotEmpty && !RegExp(...).hasMatch(email)) {
      emailError = 'Enter a valid email';
    }
    state = state.copyWith(email: email, emailError: emailError);
  }*/
  void updateEmail(String email) {
  String? emailError;
  if (email.isNotEmpty &&
      !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email)) {
    emailError = 'Please enter a valid email address';
  }
  state = state.copyWith(email: email, emailError: emailError);
}

  void updatePassword(String password) {
    String? passwordError;
    if (password.isNotEmpty && password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }
    state = state.copyWith(password: password, passwordError: passwordError);
  }
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}


final authFormProvider = StateNotifierProvider<AuthFormNotifier, AuthFormState>(
  (ref) {
    return AuthFormNotifier();
  },
  
);*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatapp/auth/model/auth_model.dart';

// ✅ 1. AUTH STATE PROVIDER (checks if user is logged in)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ✅ 2. AUTH FORM PROVIDER (manages form state)
final authFormProvider = StateNotifierProvider<AuthFormNotifier, AuthFormState>(
  (ref) => AuthFormNotifier(),
);

// ✅ 3. AUTH FORM NOTIFIER (your existing code)
class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(AuthFormState());
  
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordHidden: !state.isPasswordHidden);
  }
  
  void updateName(String name) {
    String? nameError;
    if (name.isNotEmpty && name.length < 6) {
      nameError = "Provide your full name";
    }
    state = state.copyWith(name: name, nameError: nameError);
  }
  
  void updateEmail(String email) {
    String? emailError;
    if (email.isNotEmpty &&
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(email)) {
      emailError = 'Please enter a valid email address';
    }
    state = state.copyWith(email: email, emailError: emailError);
  }

  void updatePassword(String password) {
    String? passwordError;
    if (password.isNotEmpty && password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }
    state = state.copyWith(password: password, passwordError: passwordError);
  }
  
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}