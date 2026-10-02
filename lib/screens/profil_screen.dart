import 'package:flutter/material.dart';

// Zástupná obrazovka profilu. Později v ní bude formulář
// pro jméno, hmotnost a výšku uložený přes DbHelper.ulozProfil.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Zde bude profil uživatele')),
    );
  }
}