import 'package:flutter/material.dart';
import '../../services/chatbot_service.dart';
import '../../services/last_prediction_store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbot = ChatbotService();
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    final last = LastPredictionStore.get();
    if (last != null) {
      final label = last['label']?.toString() ?? 'Unknown';
      final confidence = last['confidence'];
      final confText = confidence != null
          ? ' (confidence ${(confidence * 100).toStringAsFixed(1)}%)'
          : '';

      _messages.add(_ChatMessage(
        who: 'system',
        text: 'Latest MRI result: $label$confText\n\nAsk anything medical about this finding.',
      ));
    } else {
      _messages.add(_ChatMessage(
        who: 'system',
        text: 'No MRI result yet. Upload one from the home page.',
      ));
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(who: 'user', text: text));
      _controller.clear();
      _sending = true;
    });

    final reply =
        await _chatbot.sendMessage(text, contextInfo: LastPredictionStore.get());

    setState(() {
      _messages.add(_ChatMessage(who: 'bot', text: reply));
      _sending = false;
    });
  }

  Widget _bubble(_ChatMessage m) {
    final isUser = m.who == 'user';
    final bg = isUser ? Colors.blue[600] : Colors.grey[200];
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final txt = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: align,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          m.text,
          style: TextStyle(color: txt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Medical Consultant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_sending) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: "Ask a medical question...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sending ? null : _send,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String who;
  final String text;
  _ChatMessage({required this.who, required this.text});
}
