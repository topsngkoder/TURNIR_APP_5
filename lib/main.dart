import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Инициализация Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase успешно инициализирован');

    // Проверка подключения к Firestore
    final firestore = FirebaseFirestore.instance;
    print('Firestore инстанс создан: $firestore');

    // Проверка доступа к коллекции
    final testDoc = await firestore.collection('test').add({
      'timestamp': Timestamp.now(),
      'message': 'Test connection'
    });
    print('Тестовый документ создан с ID: ${testDoc.id}');

  } catch (e) {
    print('Ошибка при инициализации Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Турниры по бадминтону',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}