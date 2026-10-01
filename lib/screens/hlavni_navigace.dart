import 'package:flutter/material.dart';
import 'katalog_cviku_screen.dart';
import 'profil_screen.dart';

class HlavniNavigace extends StatefulWidget {
  const HlavniNavigace({super.key});

  @override
  State<HlavniNavigace> createState() => _HlavniNavigaceState();
}

class _HlavniNavigaceState extends State<HlavniNavigace> {
  int _index = 0;

  final List<Widget> _stranky = const [
    KatalogCvikuScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _stranky),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Cviky',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}