import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';
import '../core/cerber.dart';
import 'transcription_screen.dart';
import 'camera_screen.dart';
import 'bots_screen.dart';
import 'cerber_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final bridge = context.watch<AlfaBridge>();
    final cerber = context.watch<CerberGuard>();
    final statusText = switch (bridge.state) {
      BridgeState.connected => 'ALFA Bridge: połączono',
      BridgeState.connecting => 'Łączenie…',
      BridgeState.error => 'Błąd połączenia',
      BridgeState.disconnected => 'Rozłączono',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALFA × Meta'),
        actions: [
          // Mini-wskaźnik CERBER-a w pasku
          Icon(
            switch (cerber.state) {
              CerberState.alarm => Icons.warning,
              CerberState.guarding => Icons.shield,
              _ => Icons.shield_outlined,
            },
            color: switch (cerber.state) {
              CerberState.alarm => Colors.red,
              CerberState.guarding => Colors.green,
              _ => Colors.grey,
            },
            size: 18,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(child: Text(statusText, style: const TextStyle(fontSize: 12))),
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: bridge.state == BridgeState.connected ? null : bridge.connect,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [TranscriptionScreen(), CameraScreen(), BotsScreen(), CerberScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Głos'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Wzrok'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Boty ALFA'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Cerber'),
        ],
      ),
    );
  }
}
