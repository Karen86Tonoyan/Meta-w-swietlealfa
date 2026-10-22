import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/alfa_bridge.dart';
import 'core/cerber.dart';
import 'services/bot_engine.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlfaBridge()),
        ChangeNotifierProvider(create: (_) => BotEngine()),
        // CERBER: mały bot stróżujący — patrol przy starcie aplikacji
        ChangeNotifierProvider(create: (_) => CerberGuard()..patrol()),
      ],
      child: const AlfaMetaApp(),
    ),
  );
}

class AlfaMetaApp extends StatelessWidget {
  const AlfaMetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALFA × Meta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF00E5A0),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
