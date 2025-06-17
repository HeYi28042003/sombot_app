import 'package:cloud_firestore/cloud_firestore.dart';

class Users{
  final String uid;
  final String email;
   String? displayName;
   String? photoURL;
  final DateTime createdAt;
  String? phone;

  Users({
    required this.uid,
    required this.email,
     this.displayName,
     this.photoURL,
    required this.createdAt,
    this.phone,
  });

  factory Users.fromJson(Map<String, dynamic> data) {
    return Users(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['name'] ?? 'No Name',
      photoURL: data['photoURL'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'phone': phone,
    };
  }
}