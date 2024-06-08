import 'dart:async';

import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarizeit/page/record_audio/widget/list_recording_file.dart';
import 'package:sumarizeit/store/recording_store.dart';
import 'package:sumarizeit/tutorial/tutorial_component.dart';

class RecordAudioPage extends StatefulWidget {
  const RecordAudioPage({super.key});

  @override
  State<RecordAudioPage> createState() => _RecordAudioPageState();
}

class _RecordAudioPageState extends State<RecordAudioPage> {
  late final AudioRecorder _audioRecorder;
  String _nameFile = 'RecordingFile';
  String _displayName = 'RecordingFile';
  Timer? _timer;
  String _path = '';
  int _recordDuration = 0;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  final _controllerTextName = TextEditingController(text: 'RecordingFile');
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final textRecoringKey = GlobalKey();
  final recordKey = GlobalKey();
  final listRecordKey = GlobalKey();
  List<TutorialItem> items = [];

  void initItems() {
    items.addAll({
      TutorialItem(
        globalKey: textRecoringKey,
        color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Recording Name',
          content: 'You can change the recording name here',
        ),
      ),
      TutorialItem(
        globalKey: recordKey,
        color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.8),
        shapeFocus: ShapeFocus.oval,
        child: const TutorialItemContent(
          title: 'Record Button',
          content: 'Press to start recording',
        ),
      ),
      TutorialItem(
        globalKey: listRecordKey,
        color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.8),
        shapeFocus: ShapeFocus.oval,
        child: const TutorialItemContent(
          title: 'List Recording',
          content: 'You can see the list of your recording here',
        ),
      ),
    });
  }

  Future<void> _tutorail() async {
    final prefs = await SharedPreferences.getInstance();
    bool doneTutorial = prefs.getBool('doneTutorialAudio') ?? false;
    if (doneTutorial) {
      return;
    }

    initItems();
    Future.delayed(const Duration(microseconds: 200)).then((value) {
      Tutorial.showTutorial(context, items, onTutorialComplete: () {
        HapticFeedback.heavyImpact();
        prefs.setBool('doneTutorialAudio', true);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _tutorail();
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {});

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

  Future<void> _generateFileName() async {
    final now = DateTime.now();
    List<Map<String, dynamic>> nameList = context.read<RecordingStore>().state;
    int count = 1;
    // name of file auto increment and check if file name is exist
    for (int i = 0; i < nameList.length; i++) {
      if (nameList[i]['name'] == 'Recording $count') {
        count++;
        i = 0;
      }
    }
    setState(() {
      _nameFile =
          'Recording_${now.day}${now.month}${now.year}${now.hour}${now.minute}${now.second}';
      _displayName = 'Recording $count';
      _controllerTextName.text = _displayName;
    });
  }

  Future<void> _updateRecordState(RecordState recordState) async {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        String randomUUID = DateTime.now().millisecondsSinceEpoch.toString();
        context.read<RecordingStore>().add(
            '{"id": "$randomUUID","displayName": "$_displayName","name":"$_nameFile", "duration":"$_recordDuration", "date":"${DateTime.now()}", "path":"$_path"}');
        _timer?.cancel();
        _recordDuration = 0;
        _generateFileName();
        removeNotification();
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

    setState(() {
      _path = path;
    });

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
    String? audioPath = await _audioRecorder.stop();
    // log
    debugPrint('Audio file saved at $audioPath');
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        actions: [
          Container(
              key: listRecordKey,
              child: CustomBottomSheet(parentContext: context))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.1),
          TextField(
            key: textRecoringKey,
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
                _displayName = value;
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
            key: recordKey,
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
