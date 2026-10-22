import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';
import '../core/guardian_filter.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});
  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final List<String> _lines = [];
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bridge = context.read<AlfaBridge>();
    bridge.transcriptions.listen((t) => setState(() => _lines.add(t)));
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
    return Column(
      children: [
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
