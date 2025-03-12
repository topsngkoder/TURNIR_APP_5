import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import 'create_tournament_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TournamentService _tournamentService = TournamentService();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState');

    // Проверка доступа к Firestore с помощью нашего сервиса
    _tournamentService.testFirestoreAccess().then((success) {
      if (success) {
        print('HomeScreen: Проверка доступа к Firestore успешна');
      } else {
        print('HomeScreen: Проверка доступа к Firestore не удалась');

        // Показываем сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка доступа к базе данных. Проверьте подключение.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Дополнительная проверка доступа к Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      print('HomeScreen: Firestore инстанс создан: $firestore');
      print('HomeScreen: Проверка коллекции tournaments');
      firestore.collection('tournaments').get().then((snapshot) {
        print('HomeScreen: Получено ${snapshot.docs.length} документов');
        for (var doc in snapshot.docs) {
          print('HomeScreen: Документ ID: ${doc.id}, данные: ${doc.data()}');
        }
      }).catchError((error) {
        print('HomeScreen: Ошибка при получении документов: $error');
      });
    } catch (e) {
      print('HomeScreen: Ошибка при доступе к Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Турниры'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Настройка Firebase'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const [
                          Text('Для корректной работы приложения необходимо настроить правила безопасности Firestore:'),
                          SizedBox(height: 10),
                          SelectableText('''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''', style: TextStyle(fontFamily: 'monospace')),
                          SizedBox(height: 10),
                          Text('1. Перейдите в Firebase Console'),
                          Text('2. Выберите ваш проект'),
                          Text('3. Перейдите в Firestore Database'),
                          Text('4. Откройте вкладку "Правила"'),
                          Text('5. Вставьте правила выше и нажмите "Опубликовать"'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Понятно'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('HomeScreen: Обновление списка турниров');
              setState(() {
                // Обновление состояния для перезагрузки StreamBuilder
              });

              // Проверка доступа к Firestore
              _tournamentService.testFirestoreAccess().then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Подключение к Firebase успешно')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ошибка подключения к Firebase. Нажмите на иконку (i) для получения информации.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });

              // Дополнительная проверка Firestore
              FirebaseFirestore.instance.collection('tournaments').get().then((snapshot) {
                print('HomeScreen: Refresh - Получено ${snapshot.docs.length} документов');
                for (var doc in snapshot.docs) {
                  print('HomeScreen: Refresh - Документ ID: ${doc.id}, данные: ${doc.data()}');
                }
              }).catchError((error) {
                print('HomeScreen: Refresh - Ошибка при получении документов: $error');
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Список турниров',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Tournament>>(
                stream: _tournamentService.getTournaments(),
                builder: (context, snapshot) {
                  print('HomeScreen: StreamBuilder обновление, состояние: ${snapshot.connectionState}');

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('HomeScreen: Ожидание данных...');
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('HomeScreen: Ошибка: ${snapshot.error}');
                    return Center(
                      child: Text('Ошибка: ${snapshot.error}'),
                    );
                  }

                  final tournaments = snapshot.data ?? [];
                  print('HomeScreen: Получено ${tournaments.length} турниров');

                  if (tournaments.isEmpty) {
                    print('HomeScreen: Список турниров пуст');
                    return const Center(
                      child: Text(
                        'Пока нет ни одного турнира',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  print('HomeScreen: Отображение ${tournaments.length} турниров');

                  return Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Название')),
                          DataColumn(label: Text('Дата проведения')),
                          DataColumn(label: Text('Место проведения')),
                          DataColumn(label: Text('Действия')),
                        ],
                        rows: tournaments.map((tournament) {
                          return DataRow(
                            cells: [
                              DataCell(Text(tournament.name)),
                              DataCell(Text(_dateFormat.format(tournament.date))),
                              DataCell(Text(tournament.location)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Редактирование турнира (будет реализовано позже)
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _tournamentService.deleteTournament(tournament.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTournamentScreen(),
            ),
          );
        },
        label: const Text('Создать новый турнир'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}