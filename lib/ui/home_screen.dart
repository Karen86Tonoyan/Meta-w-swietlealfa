import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';
import 'transcription_screen.dart';
import 'camera_screen.dart';
import 'bots_screen.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
        children: const [TranscriptionScreen(), CameraScreen(), BotsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Głos'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Wzrok'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Boty ALFA'),
        ],
      ),
    );
  }
}
