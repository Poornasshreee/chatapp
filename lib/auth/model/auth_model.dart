
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---- Firestore user model ----
class AuthModel {
  final String uid;
  final String email;
  final String? name;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isOnline;
  final bool isEmailVerified;

  AuthModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoURL,
    required this.createdAt,
    this.lastLogin,
    this.isOnline = false,
    this.isEmailVerified = false,
  });

  factory AuthModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isOnline: data['isOnline'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isOnline': isOnline,
      'isEmailVerified': isEmailVerified,
    };
  }

  AuthModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isOnline,
    bool? isEmailVerified,
  }) {
    return AuthModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isOnline: isOnline ?? this.isOnline,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

// ---- UI form state for signup/login ----
@immutable
class AuthFormState {
  final String name;
  final String email;
  final String password;
  final bool isPasswordHidden;
  final bool isLoading;
  final String? nameError;
  final String? emailError;
  final String? passwordError;

  const AuthFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.isPasswordHidden = true,
    this.isLoading = false,
    this.nameError,
    this.emailError,
    this.passwordError,
  });

  bool get isFormValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      nameError == null &&
      emailError == null &&
      passwordError == null;

  AuthFormState copyWith({
    String? name,
    String? email,
    String? password,
    bool? isPasswordHidden,
    bool? isLoading,
    String? nameError,
    String? emailError,
    String? passwordError,
  }) {
    return AuthFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isLoading: isLoading ?? this.isLoading,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
    );
  }
}
