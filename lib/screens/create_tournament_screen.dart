import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentService = TournamentService();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTournament() {
    if (_formKey.currentState!.validate()) {
      print('Форма валидна, создаем турнир');

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

      final tournament = Tournament(
        id: '', // ID будет присвоен Firebase
        name: _nameController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
      );

      print('Создан объект турнира: ${tournament.name}, дата: ${tournament.date}');

      // Сначала проверим доступ к Firestore
      _tournamentService.testFirestoreAccess().then((success) {
        if (success) {
          print('Доступ к Firestore подтвержден, добавляем турнир');

          _tournamentService.addTournament(tournament).then((_) {
            // Закрываем диалог загрузки
            Navigator.of(context).pop();

            print('Турнир успешно добавлен в Firestore');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Турнир успешно создан')),
            );
            Navigator.pop(context); // Возвращаемся на главный экран
          }).catchError((error) {
            // Закрываем диалог загрузки
            Navigator.of(context).pop();

            print('Ошибка при добавлении турнира: $error');

            // Показываем подробную информацию об ошибке
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Ошибка при добавлении турнира'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text('Произошла ошибка при добавлении турнира в базу данных:'),
                        const SizedBox(height: 10),
                        Text(error.toString(), style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 10),
                        const Text('Пожалуйста, проверьте настройки Firebase и правила безопасности Firestore.'),
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
        } else {
          // Закрываем диалог загрузки
          Navigator.of(context).pop();

          print('Нет доступа к Firestore');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Ошибка доступа к базе данных'),
                content: const Text('Не удалось получить доступ к Firestore. Пожалуйста, проверьте настройки Firebase и правила безопасности.'),
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
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание нового турнира'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название турнира',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название турнира';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Место проведения',
                  hintText: 'Например: Спортивный комплекс "Олимпийский"',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите место проведения';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата проведения: ${_dateFormat.format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTournament,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}