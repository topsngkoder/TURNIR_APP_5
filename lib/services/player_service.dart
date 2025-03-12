import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class PlayerService {
  final CollectionReference _playersCollection = 
      FirebaseFirestore.instance.collection('players');

  // Получить всех игроков, отсортированных по рейтингу (по убыванию)
  Stream<List<Player>> getPlayers() {
    print('Запрос на получение игроков');
    return _playersCollection
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Получено ${snapshot.docs.length} игроков из Firestore');
      final players = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Документ ID: ${doc.id}, данные: $data');
        return Player.fromMap(doc.id, data);
      }).toList();
      print('Преобразовано ${players.length} игроков');
      return players;
    });
  }

  // Добавить нового игрока
  Future<void> addPlayer(Player player) async {
    try {
      print('Добавление игрока: ${player.nickname}, рейтинг: ${player.rating}');
      
      // Проверка уникальности никнейма
      final querySnapshot = await _playersCollection
          .where('nickname', isEqualTo: player.nickname)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Игрок с никнеймом "${player.nickname}" уже существует');
      }
      
      final playerData = player.toMap();
      print('Данные для Firestore: $playerData');

      // Проверка правил безопасности перед добавлением
      try {
        // Пробуем сначала получить доступ к коллекции
        await _playersCollection.limit(1).get();
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

      // Добавляем игрока
      final docRef = await _playersCollection.add(playerData);
      print('Игрок успешно добавлен с ID: ${docRef.id}');
      
      // Проверка, что игрок действительно добавлен
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
      print('Ошибка при добавлении игрока: $e');
      throw e;
    }
  }

  // Обновить игрока
  Future<void> updatePlayer(Player player) {
    return _playersCollection.doc(player.id).update(player.toMap());
  }

  // Удалить игрока
  Future<void> deletePlayer(String id) {
    return _playersCollection.doc(id).delete();
  }
}