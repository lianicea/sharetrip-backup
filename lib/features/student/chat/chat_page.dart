
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> drivers = [
    {
      'name': 'Alex Santos',
      'vehicle': 'Toyota Vios · ABC 1234',
      'message': 'I am on my way!',
      'time': '10:30 AM',
      'online': true,
      'unread': 2,
      'messages': [
        {'text': 'Good morning!', 'me': false, 'time': '10:25 AM'},
        {'text': 'Good morning, Alex!', 'me': true, 'time': '10:26 AM'},
        {'text': 'I am on my way!', 'me': false, 'time': '10:30 AM'},
      ],
    },
    {
      'name': 'Maria Reyes',
      'vehicle': 'Honda Click 160',
      'message': 'Thank you!',
      'time': 'Yesterday',
      'online': false,
      'unread': 0,
      'messages': [
        {'text': 'Thank you!', 'me': false, 'time': 'Yesterday'},
      ],
    },
  ];

  void _openChat(int index) {
    setState(() {
      drivers[index]['unread'] = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverChatScreen(
          driver: drivers[index],
          onMessageSent: (message) {
            setState(() {
              drivers[index]['message'] = message;
              drivers[index]['time'] = 'Now';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 22),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Chat with your assigned drivers',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => _openChat(index),
                    leading: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFFF0EAFF),
                          child: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        if (driver['online'])
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      driver['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          driver['vehicle'],
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          driver['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          driver['time'],
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 7),
                        if (driver['unread'] > 0)
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${driver['unread']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DRIVER CHAT SCREEN
// ==========================================

class DriverChatScreen extends StatefulWidget {
  final Map<String, dynamic> driver;
  final Function(String) onMessageSent;

  const DriverChatScreen({
    super.key,
    required this.driver,
    required this.onMessageSent,
  });

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();

    messages = List<Map<String, dynamic>>.from(
      widget.driver['messages'],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final time =
        TimeOfDay.now().format(context);

    setState(() {
      messages.add({
        'text': text,
        'me': true,
        'time': time,
      });

      widget.driver['messages'] = messages;
    });

    widget.onMessageSent(text);
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _messageBubble(Map<String, dynamic> message) {
    final bool isMe = message['me'];

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'],
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message['time'],
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : Colors.grey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF0EAFF),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.driver['name'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.driver['online']
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                      color: widget.driver['online']
                          ? Colors.green
                          : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _messageBubble(messages[index]);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(
              12, 10, 12, 12,
            ),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: const Color(0xFFF3F1F8),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
