import 'package:flutter/material.dart';
import 'hlavni_navigace.dart';

// Uvítací obrazovka. Nemá žádný měnící se stav, proto Stateless.
class UvitaciScreen extends StatelessWidget {
  const UvitaciScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold = základní kostra obrazovky (pozadí, lišty, tělo).
    return Scaffold(
      // SafeArea = obsah nezajede pod výřez displeje nebo stavovou lištu.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24), // odsazení od okrajů
          // Column = widgety pod sebou.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // svisle na střed
            children: [
              const Icon(Icons.fitness_center, size: 96),
              // SizedBox = prázdné místo mezi prvky.
              const SizedBox(height: 24),
              Text(
                'Tréninkový deník',
                // Styl textu se bere z tématu aplikace.
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Zapisuj tréninky a sleduj svůj silový progres.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                // onPressed se zavolá po klepnutí na tlačítko.
                onPressed: () {
                  // pushReplacement přepne na další obrazovku a tu
                  // současnou odstraní, takže tlačítko Zpět nevrátí na úvod.
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HlavniNavigace(),
                    ),
                  );
                },
                child: const Text('Začít'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}