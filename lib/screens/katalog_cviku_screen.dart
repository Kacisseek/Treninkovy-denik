import 'package:flutter/material.dart';

// Zatím jen zástupná obrazovka. Příště do ní přijde seznam cviků
// načtený z databáze a tlačítka pro přidání, úpravu a mazání.
class KatalogCvikuScreen extends StatelessWidget {
  const KatalogCvikuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog cviků')), // horní lišta
      body: const Center(child: Text('Zde bude seznam cviků')),
    );
  }
}