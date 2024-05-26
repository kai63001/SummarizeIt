import 'package:flutter/material.dart';

class PlayAudioPage extends StatelessWidget {
  final String audioPath;
  const PlayAudioPage({super.key, required this.audioPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Audio'),
      ),
      body: const Center(
        child: Text('Play Audio'),
      ),
    );
  }
}