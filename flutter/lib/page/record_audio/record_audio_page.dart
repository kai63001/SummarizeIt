import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  late final AudioRecorder _audioRecorder;
  final player = AudioPlayer();

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    getFileAllInPath();
  }

  Future<void> getFileAllInPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final files = Directory(path).listSync();
    print(files);
    //get file size
    //play audio
    // await player.play(DeviceFileSource('/var/mobile/Containers/Data/Application/A2BF620E-2EE3-46E2-980B-C33F5272216D/Documents/romeo.m4a'));
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final randomName = DateTime.now().millisecondsSinceEpoch;
    return '$path/romeo.m4a';
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      // Start recording to file
      final path = await getFilePath();
      // await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.pcm16bits),
      //     path: path);
      // // ... or to stream
      // await _audioRecorder
      //     .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));

      const encoder = AudioEncoder.aacLc;

      if (!await _isEncoderSupported(encoder)) {
        return;
      }

      final devs = await _audioRecorder.listInputDevices();
      debugPrint(devs.toString());

      const config = RecordConfig(encoder: encoder, numChannels: 1);

      // Record to file
      await recordFile(_audioRecorder, config);

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) async {
    final path = await _getPath();

    await recorder.start(config, path: path);
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  Future<void> stopRecording() async {
    final path = await _audioRecorder.stop();
    print(path);

    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
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
