import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final int uniqueNumber;
  final String firstName;
  final String lastName;
  final int rating;

  Player({
    required this.id,
    required this.uniqueNumber,
    required this.firstName,
    required this.lastName,
    required this.rating,
  });

  // Преобразование из Firestore
  factory Player.fromMap(String id, Map<String, dynamic> data) {
    return Player(
      id: id,
      uniqueNumber: data['uniqueNumber'] ?? 0,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      rating: data['rating'] ?? 0,
    );
  }

  // Преобразование в Firestore
  Map<String, dynamic> toMap() {
    return {
      'uniqueNumber': uniqueNumber,
      'firstName': firstName,
      'lastName': lastName,
      'rating': rating,
    };
  }

  // Полное имя игрока
  String get fullName => '$firstName $lastName';
}