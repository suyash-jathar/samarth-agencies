import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String name;
  final int age;
  final String phoneNumber;
  final DateTime timestamp;

  Patient({
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.timestamp,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'] as String,
      age: json['age'] as int,
      phoneNumber: json['phoneNumber'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'phoneNumber': phoneNumber,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}