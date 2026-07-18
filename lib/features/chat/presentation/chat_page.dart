import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat IA')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chat com IA — Sprint 3\n'
            'Staff: POST /v1/ai/chat\n'
            'Portal: POST /v1/portal/ai/chat',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
