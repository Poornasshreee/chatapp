import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Convert Firestore document to AuthModel
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

  // Convert AuthModel to Map for Firestore
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

  // Create a copy with modified fields
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