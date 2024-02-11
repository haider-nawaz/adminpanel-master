import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String cnic;
  final String firstName;
  final String lastName;
  String? id;
  String status;
  bool isVerified;

  UserModel({
    required this.cnic,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.isVerified = false,
    this.id,
  });

  factory UserModel.fromMap(DocumentSnapshot data) {
    return UserModel(
      cnic: data['cnic'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      status: data['status'],
      isVerified: data['verified'],
      id: data.id,
    );
  }

  //toMap function to convert the user object to map
  Map<String, dynamic> toMap() {
    return {
      'cnic': cnic,
      'first_name': firstName,
      'last_name': lastName,
      'status': status,
      'verified': isVerified,
    };
  }
}
