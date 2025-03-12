import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament.dart';

class TournamentService {
  final CollectionReference _tournamentsCollection = 
      FirebaseFirestore.instance.collection('tournaments');

  // Получить все турниры
  Stream<List<Tournament>> getTournaments() {
    print('Запрос на получение турниров');
    return _tournamentsCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      print('Получено ${snapshot.docs.length} турниров из Firestore');
      final tournaments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Документ ID: ${doc.id}, данные: $data');
        return Tournament.fromMap(doc.id, data);
      }).toList();
      print('Преобразовано ${tournaments.length} турниров');
      return tournaments;
    });
  }

  // Добавить новый турнир
  Future<void> addTournament(Tournament tournament) async {
    try {
      print('Добавление турнира: ${tournament.name}, дата: ${tournament.date}');
      final tournamentData = tournament.toMap();
      print('Данные для Firestore: $tournamentData');

      // Проверка правил безопасности перед добавлением
      try {
        // Пробуем сначала получить доступ к коллекции
        await _tournamentsCollection.limit(1).get();
      } catch (e) {
        print('Ошибка при проверке доступа к коллекции: $e');
        if (e.toString().contains('permission-denied')) {
          throw Exception(
            'Отказано в доступе к базе данных. Пожалуйста, проверьте правила безопасности Firestore:\n\n'
            'rules_version = \'2\';\n'
            'service cloud.firestore {\n'
            '  match /databases/{database}/documents {\n'
            '    match /{document=**} {\n'
            '      allow read, write: if true;\n'
            '    }\n'
            '  }\n'
            '}'
          );
        } else {
          throw e;
        }
      }

      // Добавляем турнир
      final docRef = await _tournamentsCollection.add(tournamentData);
      print('Турнир успешно добавлен с ID: ${docRef.id}');

      // Проверка, что турнир действительно добавлен
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        print('Проверка: документ существует в Firestore');
        print('Данные документа: ${docSnapshot.data()}');
      } else {
        print('Проверка: документ НЕ существует в Firestore!');
        throw Exception('Документ был создан, но не найден при проверке. Возможно, проблема с правами доступа.');
      }

      return;
    } catch (e) {
      print('Ошибка при добавлении турнира: $e');
      throw e;
    }
  }

  // Обновить турнир
  Future<void> updateTournament(Tournament tournament) {
    return _tournamentsCollection.doc(tournament.id).update(tournament.toMap());
  }

  // Удалить турнир
  Future<void> deleteTournament(String id) {
    return _tournamentsCollection.doc(id).delete();
  }

  // Проверка доступа к Firestore
  Future<bool> testFirestoreAccess() async {
    try {
      print('Проверка доступа к Firestore...');

      // Проверка чтения
      print('Проверка чтения...');
      try {
        final querySnapshot = await _tournamentsCollection.limit(1).get();
        print('Чтение успешно. Получено документов: ${querySnapshot.docs.length}');
      } catch (e) {
        print('Ошибка при чтении из Firestore: $e');
        print('Проверьте правила безопасности Firestore. Они должны разрешать чтение:');
        print('allow read, write: if true;');
        throw Exception('Ошибка при чтении из Firestore: $e. Проверьте правила безопасности.');
      }

      // Проверка записи
      print('Проверка записи...');
      try {
        final testDoc = await _tournamentsCollection.add({
          'test': true,
          'timestamp': Timestamp.now(),
        });
        print('Запись успешна. ID документа: ${testDoc.id}');

        // Удаление тестового документа
        await testDoc.delete();
        print('Тестовый документ удален');
      } catch (e) {
        print('Ошибка при записи в Firestore: $e');
        print('Проверьте правила безопасности Firestore. Они должны разрешать запись:');
        print('allow read, write: if true;');
        throw Exception('Ошибка при записи в Firestore: $e. Проверьте правила безопасности.');
      }

      return true;
    } catch (e) {
      print('Ошибка при проверке доступа к Firestore: $e');
      return false;
    }
  }
}