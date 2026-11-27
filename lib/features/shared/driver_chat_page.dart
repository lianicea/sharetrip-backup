import 'package:flutter/material.dart';
import '../../core/services/sharetrip_local_store.dart';

class DriverChatPage extends StatefulWidget {
  final String conversationId;
  final String title;
  final String senderRole;
  const DriverChatPage({
    super.key,
    required this.conversationId,
    required this.title,
    required this.senderRole,
  });

  @override
  State<DriverChatPage> createState() => _DriverChatPageState();
}

class _DriverChatPageState extends State<DriverChatPage> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final messages = await ShareTripLocalStore.getMessages(widget.conversationId);
    if (!mounted) return;
    setState(() { _messages = messages; _loading = false; });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final message = {
      'text': text,
      'sender': widget.senderRole,
      'time': DateTime.now().toIso8601String(),
    };
    await ShareTripLocalStore.addMessage(widget.conversationId, message);
    await _load();
  }

  String _formatTime(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    return parsed == null ? '' : parsed.toLocal().toString().substring(0, 16);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Column(children: [
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : _messages.isEmpty
          ? const Center(child: Text('No messages yet. Start the conversation.'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                final mine = item['sender'] == widget.senderRole;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: mine ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${item['text']}'),
                      const SizedBox(height: 3),
                      Text('${item['sender']} · ${_formatTime(item['time'])}',
                        style: Theme.of(context).textTheme.labelSmall),
                    ]),
                  ),
                );
              },
            )),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: const InputDecoration(hintText: 'Message driver...', border: OutlineInputBorder()),
          )),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
        ]),
      )),
    ]),
  );
}


class DriverMessagesInboxPage extends StatefulWidget {
  const DriverMessagesInboxPage({super.key});
  @override
  State<DriverMessagesInboxPage> createState() => _DriverMessagesInboxPageState();
}

class _DriverMessagesInboxPageState extends State<DriverMessagesInboxPage> {
  Map<String, List<Map<String, dynamic>>> _chats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chats = await ShareTripLocalStore.getAllChats();
    if (!mounted) return;
    setState(() { _chats = chats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student Messages')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _chats.isEmpty
        ? const Center(child: Text('No student messages yet.'))
        : ListView(
            children: _chats.entries.map((entry) {
              final last = entry.value.isEmpty ? null : entry.value.last;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text('Student · ${entry.key}'),
                subtitle: Text('${last?['text'] ?? 'Conversation'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => DriverChatPage(
                    conversationId: entry.key, title: 'Student Chat', senderRole: 'Driver')));
                  _load();
                },
              );
            }).toList(),
          ),
  );
}
