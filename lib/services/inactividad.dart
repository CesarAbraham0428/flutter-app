// lib/services/inactividad.dart
import 'dart:async';
import 'package:flutter/material.dart';

class Inactividad {
  static final Inactividad _instance = Inactividad._internal();
  factory Inactividad() => _instance;
  Inactividad._internal();

  Timer? _inactividadContador;
  final int _tiempoFuera = 300; // Tiempo de inactividad en segundos

  void initialize(BuildContext context) {
    _resetTimer(context);
  }

  void _resetTimer(BuildContext context) {
    _inactividadContador?.cancel();
    _inactividadContador = Timer(Duration(seconds: _tiempoFuera), () {
      _logout(context);
    });
  }

  void startTimer(BuildContext context) {
    _resetTimer(context);
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void dispose() {
    _inactividadContador?.cancel();
  }
}
