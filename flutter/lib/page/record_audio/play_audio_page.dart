import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sumarizeit/store/recording_store.dart';

class PlayAudioPage extends StatefulWidget {
  final String audioPath;
  final String duration;
  final String name;
  final String id;
  const PlayAudioPage(
      {super.key,
      required this.audioPath,
      required this.duration,
      required this.id,
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
        //option
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return DraggableScrollableSheet(
                      initialChildSize: 0.3, // Initial height of the Sheet
                      minChildSize: 0.1, // Minimum height of the Sheet
                      maxChildSize: 1, // Maximum height of the Sheet
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Container(
                            color: const Color(0xFF14141A),
                            child: Column(
                              children: [
                                // Custom drag handle
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  height: 5,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[
                                        300], // Change this to your desired color
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    HapticFeedback.heavyImpact(),
                                    Navigator.pop(context),
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 43, 43, 54),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                    Icons.short_text_outlined),
                                              ),
                                              const Text(
                                                'Summary this audio',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ])),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    HapticFeedback.heavyImpact(),
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      text: 'Do you want to delete this audio?',
                                      confirmBtnText: 'Yes',
                                      cancelBtnText: 'No',
                                      confirmBtnColor: Colors.green,
                                      onConfirmBtnTap: () => {
                                        HapticFeedback.heavyImpact(),
                                        _pauseAudio(),
                                        Navigator.pop(context),
                                        context
                                            .read<RecordingStore>()
                                            .deleteRecording(widget.id),
                                        //pop 2 times to close the bottom sheet
                                        Navigator.pop(context),
                                        Navigator.pop(context),
                                      },
                                    )
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 43, 43, 54),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(Icons.delete),
                                              ),
                                              const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ])),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              );
            },
            icon: const Icon(Icons.menu),
          ),
        ],
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
      return GestureDetector(
        onTap: _pauseAudio,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFD789),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Icon(
              Icons.pause,
              color: Colors.black,
              size: 40,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _playAudio,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFD789),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 40,
            ),
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
