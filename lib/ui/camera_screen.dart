import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';

/// Podgląd klatek z kamery okularów przekazywanych przez Bridge.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Uint8List? _lastFrame;

  @override
  void initState() {
    super.initState();
    context.read<AlfaBridge>().frames.listen((f) => setState(() => _lastFrame = f));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _lastFrame == null
          ? const Text('Brak klatek — połącz Bridge i uruchom strumień z okularów.')
          : Image.memory(_lastFrame!, gaplessPlayback: true),
    );
  }
}
