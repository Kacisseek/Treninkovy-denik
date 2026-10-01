import 'package:flutter/material.dart';

class KatalogCvikuScreen extends StatelessWidget {
  const KatalogCvikuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog cviků')),
      body: const Center(child: Text('Zde bude seznam cviků')),
    );
  }
}