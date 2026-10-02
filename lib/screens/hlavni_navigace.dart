import 'package:flutter/material.dart';
import 'katalog_cviku_screen.dart';
import 'profil_screen.dart';

// StatefulWidget = widget s proměnným stavem. Tady si pamatuje,
// která záložka spodní lišty je právě vybraná.
class HlavniNavigace extends StatefulWidget {
  const HlavniNavigace({super.key});

  @override
  State<HlavniNavigace> createState() => _HlavniNavigaceState();
}

// Třída State drží samotný stav (proměnné, které se mění).
class _HlavniNavigaceState extends State<HlavniNavigace> {
  // Index vybrané záložky: 0 = Cviky, 1 = Profil.
  int _index = 0;

  // Seznam stránek. Pořadí odpovídá pořadí tlačítek v liště.
  final List<Widget> _stranky = const [
    KatalogCvikuScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack zobrazí jen stránku podle indexu, ostatní jsou
      // skryté, ale zachovají si svůj stav (např. rozepsaný formulář).
      body: IndexedStack(index: _index, children: _stranky),
      // Spodní navigační lišta.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        // setState změní hodnotu A řekne Flutteru, ať obrazovku
        // překreslí. Bez setState by se po klepnutí nic nestalo.
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