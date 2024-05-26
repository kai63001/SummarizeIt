import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:sumarizeit/page/record_audio/widget/list_recording_file.dart';
import 'package:sumarizeit/store/recording_store.dart';

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  late final AudioRecorder _audioRecorder;
  final player = AudioPlayer();
  String _nameFile = 'RecordingFile';
  Timer? _timer;
  int _recordDuration = 0;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  final _controllerTextName = TextEditingController(text: 'RecordingFile');
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {});

    getFileAllInPath();
    _generateFileName();

    //Notification
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _generateFileName() {
    final now = DateTime.now();
    setState(() {
      _nameFile =
          'Recording_${now.day}${now.month}${now.year}${now.hour}${now.minute}${now.second}';
      _controllerTextName.text = _nameFile;
    });
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
      context
          .read<RecordingStore>()
          .add('{"name":"$_nameFile", "duration":"$_recordDuration", "date":"${DateTime.now()}"}');
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<void> showPersistentNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // This makes the notification persistent
      autoCancel: false, // Prevents the user from swiping away the notification
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Timer Running',
      'Your timer is running',
      platformChannelSpecifics,
      payload: 'stop',
    );
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

    // file name is 'Recording_day_month_year_time.m4a'
    // setState(() {
    //   _nameFile = files[0].path.split('/').last;
    // });

    //get file size
    //play audio
    // await player.play(DeviceFileSource('/var/mobile/Containers/Data/Application/A2BF620E-2EE3-46E2-980B-C33F5272216D/Documents/romeo.m4a'));
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      HapticFeedback.heavyImpact();
      const encoder = AudioEncoder.aacLc;

      if (!await _isEncoderSupported(encoder)) {
        return;
      }

      final devs = await _audioRecorder.listInputDevices();
      debugPrint(devs.toString());

      const config = RecordConfig(encoder: encoder, numChannels: 1);

      // Record to file
      await recordFile(_audioRecorder, config);
      showPersistentNotification();
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
      '$_nameFile.m4a',
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
    _generateFileName();
    removeNotification();

   
  }

  Future<void> pauseRecording() async {
    await _audioRecorder.pause();
  }

  Future<void> resumeRecording() async {
    await _audioRecorder.resume();
  }

  void removeNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    removeNotification();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        // action for show bottom sheet about list of recording file
        actions: [CustomBottomSheet(parentContext: context)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controllerTextName,
              readOnly: _recordState != RecordState.stop,
              decoration: const InputDecoration(
                hintText: 'File name',
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              onChanged: (value) {
                setState(() {
                  _nameFile = value;
                });
              },
            ),
            const SizedBox(height: 100),
            if (_recordState == RecordState.record ||
                _recordState == RecordState.pause)
              _buildTimer(),
            if (_recordState == RecordState.record ||
                _recordState == RecordState.pause)
              const SizedBox(height: 20),
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
        if (_recordState == RecordState.stop) _micDisplay(),
        if (_recordState == RecordState.record)
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD789),
              borderRadius: BorderRadius.circular(200),
            ),
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.black),
              onPressed: pauseRecording,
            ),
          ),
        if (_recordState == RecordState.pause)
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD789),
              borderRadius: BorderRadius.circular(200),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.black,
              ),
              onPressed: resumeRecording,
            ),
          ),
        if (_recordState != RecordState.stop)
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(200),
            ),
            child: IconButton(
              icon: const Icon(Icons.stop),
              onPressed: stopRecording,
            ),
          )
      ],
    );
  }

  Widget _micDisplay() {
    return Column(
      children: [
        GestureDetector(
          onTap: startRecording,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 33, 28, 20),
              borderRadius: BorderRadius.circular(200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 59, 50, 34),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    // background color and padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD789),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Icon(
                        Icons.mic,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Press to start recording',
          style: TextStyle(color: Colors.grey, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.white, fontSize: 40),
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
