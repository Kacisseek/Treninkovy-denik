import 'package:flutter/material.dart';
import 'hlavni_navigace.dart';

class UvitaciScreen extends StatelessWidget {
  const UvitaciScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 96),
              const SizedBox(height: 24),
              Text(
                'Tréninkový deník',
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
                onPressed: () {
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