import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/alfa_bridge.dart';
import '../core/guardian_filter.dart';
import '../services/bot_engine.dart';

class BotsScreen extends StatefulWidget {
  const BotsScreen({super.key});
  @override
  State<BotsScreen> createState() => _BotsScreenState();
}

class _BotsScreenState extends State<BotsScreen> {
  final _prompt = TextEditingController();

  void _send() {
    final engine = context.read<BotEngine>();
    final bridge = context.read<AlfaBridge>();
    final text = _prompt.text.trim();
    if (text.isEmpty) return;
    final block = GuardianFilter.check(text);
    if (block != null) {
      engine.addBotReply(engine.activeBotId, '⛔ $block');
    } else {
      engine.addUserMessage(text);
      bridge.askBot(engine.activeBotId, text);
    }
    _prompt.clear();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<BotEngine>();
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: [
              for (final b in engine.bots)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: b.id == engine.activeBotId,
                    onSelected: (_) => engine.select(b.id),
                    avatar: const Icon(Icons.smart_toy, size: 18),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(b.ritualName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(b.role, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: engine.history.length,
            itemBuilder: (_, i) {
              final m = engine.history[i];
              return Align(
                alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(m.fromUser ? m.text : '[${m.bot}] ${m.text}'),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prompt,
                    decoration: InputDecoration(
                      hintText: 'Zapytaj ${engine.active.id}…',
                      border: const OutlineInputBorder(),
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
