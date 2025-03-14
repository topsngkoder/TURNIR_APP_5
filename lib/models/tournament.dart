import 'package:cloud_firestore/cloud_firestore.dart';

class Tournament {
  final String id;
  final String name;
  final DateTime date;
  final String location;

  Tournament({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
  });

  // Преобразование из Firestore
  factory Tournament.fromMap(String id, Map<String, dynamic> data) {
    return Tournament(
      id: id,
      name: data['name'] ?? '',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      location: data['location'] ?? '',
    );
  }

  // Преобразование в Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'location': location,
    };
  }
}