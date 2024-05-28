import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayAudioPage extends StatefulWidget {
  final String audioPath;
  final String duration;
  final String name;
  const PlayAudioPage(
      {super.key,
      required this.audioPath,
      required this.duration,
      required this.name});

  @override
  State<PlayAudioPage> createState() => _PlayAudioPageState();
}

class _PlayAudioPageState extends State<PlayAudioPage> {
  late AudioPlayer audioPlayer;
  Duration totalDuration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  StreamSubscription<Duration>? durationSubscription;
  StreamSubscription<Duration>? positionSubscription;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    durationSubscription = audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => totalDuration = d);
    });
    positionSubscription = audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = const Duration();
      });
    });
  }

  void _playAudio() {
    audioPlayer.play(DeviceFileSource(widget.audioPath));
    setState(() {
      isPlaying = true;
    });
  }

  void _pauseAudio() {
    audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void _seekAudio(double seconds) {
    Duration newDuration = Duration(seconds: seconds.toInt());
    audioPlayer.seek(newDuration);
  }

  @override
  void dispose() {
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Audio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(widget.name,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimer(int.parse(position.inSeconds.toString())),
                      _buildTimer(int.parse(widget.duration)),
                    ],
                  ),
                ),
                Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: totalDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _seekAudio(value);
                      position = Duration(seconds: value.toInt());
                    });
                  },
                ),
              ],
            ),
            _controllerAudio(),
          ],
        ),
      ),
    );
  }

  Widget _controllerAudio() {
    if (isPlaying) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFD789),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: _pauseAudio,
            icon: const Icon(Icons.pause, color: Colors.black),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFD789),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: _playAudio,
            icon: const Icon(Icons.play_arrow, color: Colors.black),
          ),
        ),
      );
    }
  }

  Widget _buildTimer(int recordDuration) {
    final String minutes = _formatNumber(recordDuration ~/ 60);
    final String seconds = _formatNumber(recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
