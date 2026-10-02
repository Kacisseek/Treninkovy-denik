import 'package:flutter/material.dart';
import 'screens/uvitaci_screen.dart';

// Vstupní bod aplikace. Odtud se vše spouští.
void main() {
  // runApp spustí kořenový widget. V Flutteru je všechno widget
  // (tlačítko, text, celá obrazovka).
  runApp(const MyApp());
}

// StatelessWidget = widget bez proměnného stavu, vykreslí se pořád stejně.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build() popisuje, jak widget vypadá. Flutter ho volá při vykreslení.
  @override
  Widget build(BuildContext context) {
    // MaterialApp = základ aplikace ve stylu Material Design.
    return MaterialApp(
      title: 'Tréninkový deník',
      debugShowCheckedModeBanner: false, // skryje pásek "DEBUG"
      theme: ThemeData(
        // Z jedné barvy (seed) se vygeneruje celá barevná paleta.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // home = první obrazovka, která se po spuštění zobrazí.
      home: const UvitaciScreen(),
    );
  }
}