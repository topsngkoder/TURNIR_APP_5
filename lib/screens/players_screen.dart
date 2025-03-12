import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_service.dart';
import 'create_player_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final PlayerService _playerService = PlayerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игроки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Обновление состояния для перезагрузки StreamBuilder
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
              'Список игроков',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: _playerService.getPlayers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка: ${snapshot.error}'),
                    );
                  }

                  final players = snapshot.data ?? [];

                  if (players.isEmpty) {
                    return const Center(
                      child: Text(
                        'Пока нет ни одного игрока',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              player.nickname.isNotEmpty 
                                  ? player.nickname[0].toUpperCase() 
                                  : '?',
                            ),
                          ),
                          title: Text(player.nickname),
                          subtitle: Text(player.fullName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  'Рейтинг: ${player.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Редактирование игрока (будет реализовано позже)
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Удаление игрока'),
                                      content: Text(
                                        'Вы уверены, что хотите удалить игрока ${player.nickname}?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Отмена'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _playerService.deletePlayer(player.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Удалить'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
              builder: (context) => const CreatePlayerScreen(),
            ),
          );
        },
        label: const Text('Добавить игрока'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}