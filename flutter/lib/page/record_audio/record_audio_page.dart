import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  late final AudioRecorder _audioRecorder;
  final player = AudioPlayer();
  Timer? _timer;
  int _recordDuration = 0;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
    });

    getFileAllInPath();
  }

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
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

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      // Start recording to file
      const encoder = AudioEncoder.aacLc;

      if (!await _isEncoderSupported(encoder)) {
        return;
      }

      final devs = await _audioRecorder.listInputDevices();
      debugPrint(devs.toString());

      const config = RecordConfig(encoder: encoder, numChannels: 1);

      // Record to file
      await recordFile(_audioRecorder, config);
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
    await _audioRecorder.stop();
  }

  Future<void> pauseRecording() async {
    await _audioRecorder.pause();
  }

  Future<void> resumeRecording() async {
    await _audioRecorder.resume();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
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
            if (_recordState == RecordState.record) _buildTimer(),
            _controller(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _controller() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_recordState == RecordState.stop)
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: startRecording,
          ),
        if (_recordState == RecordState.record)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: pauseRecording,
          ),
        if (_recordState == RecordState.pause)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: resumeRecording,
          ),
        if (_recordState != RecordState.stop)
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: stopRecording,
          )
      ],
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }
}
