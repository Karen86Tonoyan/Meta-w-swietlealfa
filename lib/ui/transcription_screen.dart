import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';
import '../core/guardian_filter.dart';
import '../services/muse_transcribe.dart';
import '../services/meta_wearables_channel.dart';

/// Głos: STT na żywo z okularów przez Muse Voice Transcribe (realtime WS).
/// Fallback na wpisywanie tekstu z klawiatury.
class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});
  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final List<String> _lines = [];
  final _input = TextEditingController();
  final _stt = MuseTranscribe();
  final _glasses = MetaWearablesChannel();
  String _partial = '';

  @override
  void initState() {
    super.initState();
    _stt.partials.listen((t) => setState(() => _partial = t));
    _stt.finals.listen((t) => setState(() {
      _lines.add('🎙 $t');
      _partial = '';
    }));
    // Ramki audio z okularów → STT
    _glasses.events().listen((e) {
      if (e is Uint8List) _stt.sendAudio(e);
    });
  }

  Future<void> _toggleStt() async {
    if (_stt.state == SttState.streaming) {
      await _stt.stop();
    } else {
      final ok = await _stt.start(language: 'pl');
      if (!ok && mounted) {
        setState(() => _lines.add('⚠ STT: brak połączenia — sprawdź MODEL_API_KEY'));
      }
    }
    setState(() {});
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final block = GuardianFilter.check(text);
    if (block != null) {
      setState(() => _lines.add('⛔ $block'));
    } else {
      context.read<AlfaBridge>().send({'type': 'voice_text', 'text': text});
      setState(() => _lines.add('Ty: $text'));
    }
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final live = _stt.state == SttState.streaming;
    return Column(
      children: [
        Material(
          color: live ? Colors.green.withOpacity(0.15) : null,
          child: ListTile(
            leading: Icon(live ? Icons.mic : Icons.mic_off, color: live ? Colors.green : null),
            title: Text(live ? 'Muse Voice Transcribe — NA ŻYWO' : 'STT wyłączone'),
            subtitle: const Text('muse-voice-transcribe-1.0 · PL · diaryzacja · keyword biasing ALFA'),
            trailing: FilledButton(
              onPressed: _toggleStt,
              child: Text(live ? 'Stop' : 'Start'),
            ),
          ),
        ),
        if (_partial.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(alignment: Alignment.centerLeft, child: Text(_partial, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _lines.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_lines[i]),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: 'Powiedz lub wpisz do ALFA…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
