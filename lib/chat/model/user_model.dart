class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
              : (map['lastSeen'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
    };
  }
}