import 'package:diary_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class SoulNoteApp extends StatelessWidget {
  const SoulNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoulNote',
      home: const AuthGate(),
    );
  }
}
