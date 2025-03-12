import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class PlayerService {
  final CollectionReference _playersCollection = 
      FirebaseFirestore.instance.collection('players');

  // Получить всех игроков, отсортированных по рейтингу (по убыванию)
  Stream<List<Player>> getPlayers() {
    print('Запрос на получение игроков');
    return _playersCollection
        .orderBy('doublesRating', descending: true)
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
      print('Добавление игрока с номером: ${player.uniqueNumber}, одиночный рейтинг: ${player.singlesRating}, парный рейтинг: ${player.doublesRating}');
      
      // Проверка уникальности уникального номера
      final querySnapshot = await _playersCollection
          .where('uniqueNumber', isEqualTo: player.uniqueNumber)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Игрок с номером "${player.uniqueNumber}" уже существует');
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

  Future<void> updatePlayerRatingFromWebsite(int uniqueNumber) async {
    try {
      final url = Uri.parse('https://badminton4u.ru/players/$uniqueNumber?type=d');
      print('Запрос к URL: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Успешный ответ от сервера');
        final document = html_parser.parse(response.body);

        // Ищем элемент с классом 'player-info'
        final playerInfoElement = document.querySelector('.player-info');

        if (playerInfoElement != null) {
          // Извлекаем текст из элемента
          final playerInfoText = playerInfoElement.text;

          // Парсим рейтинги из текста
          final singlesRatingText = playerInfoText.split('Одиночный рейтинг:').last.split('Парный рейтинг:').first.trim();
          final doublesRatingText = playerInfoText.split('Парный рейтинг:').last.split('последние 10за все время').first.trim();

          final singlesRating = int.tryParse(singlesRatingText) ?? 0;
          final doublesRating = int.tryParse(doublesRatingText) ?? 0;

          print('Одиночный рейтинг: $singlesRating');
          print('Парный рейтинг: $doublesRating');

          // Обновляем рейтинг игрока в Firestore
          final querySnapshot = await _playersCollection
              .where('uniqueNumber', isEqualTo: uniqueNumber)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docRef = querySnapshot.docs.first.reference;
            await docRef.update({
              'singlesRating': singlesRating,
              'doublesRating': doublesRating,
            });
            print('Рейтинг игрока обновлен в Firestore');
          } else {
            print('Игрок с номером $uniqueNumber не найден в базе данных.');
          }
        } else {
          print('Элемент с классом player-info не найден.');
        }
      } else {
        print('Ошибка при получении данных с сайта: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при обновлении рейтинга: $e');
    }
  }

  // Пример функций для извлечения рейтинга из HTML
  int extractSinglesRating(String html) {
    final document = html_parser.parse(html);
    final singlesRatingElement = document.body?.text.split('Одиночный рейтинг:').last.split('Парный рейтинг:').first.trim();
    return int.tryParse(singlesRatingElement ?? '0') ?? 0;
  }

  int extractDoublesRating(String html) {
    final document = html_parser.parse(html);
    final doublesRatingElement = document.body?.text.split('Парный рейтинг:').last.split('последние 10за все время').first.trim();
    return int.tryParse(doublesRatingElement ?? '0') ?? 0;
  }

  Future<void> fetchPlayerRatings(int playerNumber) async {
    final url = Uri.parse('https://badminton4u.ru/players/$playerNumber?type=d');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);

      // Ищем элемент с классом 'player-info'
      final playerInfoElement = document.querySelector('.player-info');

      if (playerInfoElement != null) {
        // Извлекаем текст из элемента
        final playerInfoText = playerInfoElement.text;

        // Парсим рейтинги из текста
        final singlesRatingText = playerInfoText.split('Одиночный рейтинг:').last.split('Парный рейтинг:').first.trim();
        final doublesRatingText = playerInfoText.split('Парный рейтинг:').last.split('последние 10за все время').first.trim();

        final singlesRating = int.tryParse(singlesRatingText) ?? 0;
        final doublesRating = int.tryParse(doublesRatingText) ?? 0;

        print('Одиночный рейтинг: $singlesRating');
        print('Парный рейтинг: $doublesRating');
      } else {
        print('Элемент с классом player-info не найден.');
      }
    } else {
      print('Ошибка при получении данных: ${response.statusCode}');
    }
  }
}