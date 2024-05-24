import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  final record = AudioRecorder();

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    getFileAllInPath();
  }

  Future<void> getFileAllInPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final files = Directory(path).listSync();
    print(files);
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final randomName = DateTime.now().millisecondsSinceEpoch;
    return '$path/$randomName.m4a';
  }

  Future<void> startRecording() async {
    if (await record.hasPermission()) {
      // Start recording to file
      final path = await getFilePath();
      print(path);
      await record.start(const RecordConfig(), path: path);
      // ... or to stream
      await record
          .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    await record.stop();

    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
