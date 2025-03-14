import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class CreatePlayerScreen extends StatefulWidget {
  const CreatePlayerScreen({super.key});

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerService = PlayerService();
  
  final _nicknameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _uniqueNumberController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _uniqueNumberController.dispose();
    super.dispose();
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      print('Форма валидна, создаем игрока');
      
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      final player = Player(
        id: '', // ID будет присвоен Firebase
        uniqueNumber: int.parse(_uniqueNumberController.text.trim()),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        singlesRating: 0, // Установите значение по умолчанию для одиночного рейтинга
        doublesRating: 0, // Установите значение по умолчанию для парного рейтинга
      );
      
      print('Создан объект игрока: ${player.uniqueNumber}');

      _playerService.addPlayer(player).then((_) {
        // Закрываем диалог загрузки
        Navigator.of(context).pop();
        
        print('Игрок успешно добавлен в Firestore');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Игрок успешно создан')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        // Закрываем диалог загрузки
        Navigator.of(context).pop();
        
        print('Ошибка при добавлении игрока: $error');
        
        // Показываем подробную информацию об ошибке
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ошибка при добавлении игрока'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('Произошла ошибка при добавлении игрока в базу данных:'),
                    const SizedBox(height: 10),
                    Text(error.toString(), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание нового игрока'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _uniqueNumberController,
                decoration: const InputDecoration(
                  labelText: 'Уникальный номер *',
                  hintText: 'Уникальный цифровой номер игрока',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите уникальный номер';
                  }
                  try {
                    int.parse(value);
                  } catch (e) {
                    return 'Уникальный номер должен быть числом';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Фамилия *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите фамилию';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePlayer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}