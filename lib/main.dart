import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iniciofront/auth/login.dart';
import 'package:iniciofront/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inicio del Proyecto Wasiman',
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white)),
      home: HomePage(), // Inicia con la pantalla de splash
    );
  }
}
