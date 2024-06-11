// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarizeit/main.dart';
import 'package:sumarizeit/store/deviceId_store.dart';
import 'package:sumarizeit/store/history_store.dart';
import 'package:sumarizeit/store/purchase_store.dart';
import 'package:sumarizeit/store/saved_time_store.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contant/contants.dart';
import 'dart:convert';

class SummaryDone extends StatefulWidget {
  const SummaryDone(
      {super.key,
      this.text = '',
      required this.type,
      this.title = '',
      this.done = false,
      this.pathAudioFile = '',
      this.audioId = '',
      this.audioDuration = 0,
      this.youtubeUrl = '',
      this.lang = 'en',
      this.tutorial = false,
      this.historyId = ''});

  final String text;
  final String type;
  final String title;
  final String pathAudioFile;
  final String audioId;
  final double audioDuration;
  final String lang;
  final bool done;
  final String historyId;
  final String youtubeUrl;
  final bool tutorial;

  @override
  State<SummaryDone> createState() => _SummaryDoneState();
}

class _SummaryDoneState extends State<SummaryDone>
    with SingleTickerProviderStateMixin {
  DateFormat formatDate = DateFormat("HH:mm dd-MM-yy");
  bool _isSummary = false;
  String _summaryText = '';
  String _originalText = '';
  String _transcriptText = '';
  String _titleText = '';
  String _date = '';
  String _youtubeUrl = '';
  String _displayText = 'original';
  String _originalType = 'original';
  String _shorter = '';
  String _longer = '';
  String _id = '';
  late TabController _tabController;
  final ThemeData theme = ThemeData();
  //init
  @override
  void initState() {
    super.initState();
    setState(() {
      _id = DateTime.now().toString();
      _youtubeUrl = widget.youtubeUrl;
      _date = formatDate.format(DateTime.parse(DateTime.now().toString()));
    });
    _tabController = TabController(length: 2, vsync: this);
    if (widget.tutorial) {
      _onTutorial();
      return;
    }
    _onSummary();
  }

  Future<void> _onTutorial() async {
    //Delay for tutorial 4 second
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _summaryText =
            'The speaker recounts breaking into his own home after losing his keys, highlighting the impact of stress on decision-making. He explores the concept of a pre-mortem, anticipating potential failures and mitigating risks. Using examples from everyday life and medical decisions, he emphasizes the importance of informed decision-making, such as considering the number needed to treat in medical interventions. The pre-mortem approach aims to prepare for scenarios under stress, promoting rational thinking and minimizing potential harm. Practical suggestions like designating spots for important items and discussing risks with doctors are advised to prevent detrimental outcomes.';
        _originalText = tutorailOriginalText;
        _titleText = widget.title;
        _date = formatDate.format(DateTime.parse(DateTime.now().toString()));
        _youtubeUrl = widget.youtubeUrl;
        _isSummary = true;
      });
      alertSaveTime(12.20);
      saveToHistory();
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('doneTutorial', true);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void alertSaveTime(double time) {
    var formattedTime = time.toStringAsFixed(2);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Time Saved',
      text: 'You saved $formattedTime minutes',
    );
    timeSavedSaveToStorage(time);
  }

  void timeSavedSaveToStorage(double time) async {
    final timeBloc = context.read<SavedTimeStore>();
    timeBloc.increment(time);
  }

  Future _getHistoryById() async {
    context.read<HistoryStore>().state.forEach((element) {
      if (element['id'] == widget.historyId) {
        setState(() {
          _id = element['id'];
          _summaryText = element['summary'];
          _originalText = element['original'];
          _titleText = element['title'];
          _transcriptText = element['transcript'];
          _date = formatDate.format(DateTime.parse(element['date']));
          _youtubeUrl = element['youtubeUrl'];
          _shorter = element['shorter'] ?? '';
          _longer = element['longer'] ?? '';
          _isSummary = true;
        });
      }
    });
  }

  bool _middlewareCheckAudioHistory() {
    List<Map<String, dynamic>> history = context.read<HistoryStore>().state;
    for (var i = 0; i < history.length; i++) {
      if (history[i]['type'] == 'audio-summary' &&
          history[i]['audioId'] == widget.audioId) {
        setState(() {
          _id = history[i]['id'];
          _summaryText = history[i]['summary'];
          _originalText = history[i]['original'];
          _titleText = history[i]['title'];
          _transcriptText = history[i]['transcript'];
          _date = formatDate.format(DateTime.parse(history[i]['date']));
          _shorter = history[i]['shorter'] ?? '';
          ;
          _longer = history[i]['longer'] ?? '';
          ;
          _isSummary = true;
        });
        return true;
      }
    }

    return false;
  }

  Future<bool> _checkProOrNot() async {
    bool pro = context.read<PurchaseStore>().state['isPro'] ?? false;
    debugPrint('pro: $pro');
    if (!pro) {
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
      debugPrint("paywallResult: $paywallResult");
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const MyApp(),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
      return false;
    }
    return true;
  }

  bool _middlewareCheckYoutubeHistory() {
    List<Map<String, dynamic>> history = context.read<HistoryStore>().state;
    for (var i = 0; i < history.length; i++) {
      if (history[i]['type'] == 'youtube-summary' &&
          history[i]['youtubeUrl'] == widget.youtubeUrl &&
          history[i]['lang'] == widget.lang) {
        setState(() {
          _id = history[i]['id'];
          _summaryText = history[i]['summary'];
          _originalText = history[i]['original'];
          _titleText = history[i]['title'];
          _transcriptText = history[i]['transcript'];
          _date = formatDate.format(DateTime.parse(history[i]['date']));
          _youtubeUrl = history[i]['youtubeUrl'];
          _shorter = history[i]['shorter'] ?? '';
          _longer = history[i]['longer'] ?? '';
          _isSummary = true;
        });
        return true;
      }
    }

    return false;
  }

  Future _onSummary() async {
    var unescape = HtmlUnescape();
    Uri api;
    Map<String, String> body;
    if (widget.done && widget.historyId.isNotEmpty) {
      _getHistoryById();
      return;
    }
    if (_middlewareCheckAudioHistory()) {
      return;
    }
    if (_middlewareCheckYoutubeHistory()) {
      return;
    }

    if (await _checkProOrNot() == false) {
      return;
    }

    http.Response response;

    // ignore: use_build_context_synchronously
    String deviceId = context.read<DeviceIdStore>().state;
    if (deviceId.isEmpty) {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please try again',
      );
      return;
    }
    if (widget.type == 'text-summary') {
      api = Uri.parse('$apiUrl/summary/text-summary');
      body = {'text': widget.text, 'deviceId': deviceId};
      response = await http.post(
        api,
        body: body,
      );
    } else if (widget.type == 'audio-summary') {
      api = Uri.parse('$apiUrl/summary/audio-summary');
      var request = http.MultipartRequest('POST', api);
      request.fields['deviceId'] = deviceId;
      request.files.add(await http.MultipartFile.fromPath(
          'audio', widget.pathAudioFile,
          contentType: MediaType('audio', 'm4a')));
      response = await http.Response.fromStream(await request.send());
    } else {
      api = Uri.parse('$apiUrl/summary/youtube-summary');
      body = {
        'url': widget.text,
        'deviceId': deviceId,
        'title': widget.title,
        'lang': widget.lang
      };
      response = await http.post(
        api,
        body: body,
      );
    }

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body); // Add this line
      if (widget.type == 'text-summary') {
        setState(() {
          _isSummary = true;
          _summaryText =
              responseBody['data']['summary']['summary']; // Change this line
          _originalText = widget.text;
          _titleText = responseBody['data']['summary']['title'];
          // parse to duble
        });
        double time =
            double.parse(responseBody['data']['summary']['time'].toString());
        alertSaveTime(time);
      } else if (widget.type == 'audio-summary') {
        setState(() {
          _isSummary = true;
          _summaryText =
              responseBody['data']['summary']['summary']; // Change this line
          _originalText = responseBody['data']['text'];
          _titleText = responseBody['data']['summary']['title'];
          _youtubeUrl = widget.youtubeUrl;
        });
        try {
          //get data audio with id
          if (widget.audioDuration != 0) {
            double time = widget.audioDuration / 60; //convert to minutes
            double rounded = double.parse(time.toStringAsFixed(2));
            alertSaveTime(rounded);
          }
        } catch (e) {
          double time =
              (responseBody['data']['summary']['time'] as num).toDouble();
          alertSaveTime(time);
        }
      } else {
        // * youtube summary
        setState(() {
          _isSummary = true;
          _summaryText = responseBody['data']['summary']; // Change this line
          _originalText = unescape.convert(responseBody['data']['text']);
          if (responseBody['data']['transcript'] != null ||
              responseBody['data']['transcript'] != '') {
            _transcriptText = responseBody['data']['transcript'];
          }
          _titleText = widget.title;
        });
        double time = (responseBody['data']['time'] as num).toDouble();
        alertSaveTime(time);
        if (_transcriptText.isNotEmpty) {
          setState(() {
            _originalType = 'transcript';
          });
        }
      }
      saveToHistory();
    } else {
      var responseBody = jsonDecode(response.body); // Add this line
      String message = responseBody['message'] ?? 'Failed to load summary';
      if (message == 'Error fetching transcript') {
        Navigator.pop(context);
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title:
              'This video has no transcript. feature on beta, please contact us if you need this feature',
          text: '🚨 $message',
        );
      }
      //back to pop
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Summary Failed',
        text: '🚨 $message',
      );
    }
  }

  Future _onFetchYoutubeVideo(String youtubeUrl, String deviceId) async {
    Uri api;
    Map<String, String> body;
    http.Response response;
    api = Uri.parse('$apiUrl/summary/youtube-summary-download');
    body = {'url': widget.text, 'deviceId': deviceId, 'title': widget.title};
    response = await http.post(
      api,
      body: body,
    );
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body); // Add this line
      setState(() {
        _isSummary = true;
        _summaryText = responseBody['data']['summary']; // Change this line
        _originalText = responseBody['data']['text'];
        _titleText = widget.title;
      });
      double time = (responseBody['data']['time'] as num).toDouble();
      alertSaveTime(time);
    } else {
      var responseBody = jsonDecode(response.body); // Add this line
      String message = responseBody['message'] ?? 'Failed to load summary';
      //back to pop
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Summary Failed',
        text: '🚨 $message',
      );
    }
  }

  Future<void> _onFetchShorterOrLonger(String type) async {
    if (await _checkProOrNot() == false) {
      return;
    }
    Navigator.pop(context);
    setState(() {
      _isSummary = false;
    });
    if (type == 'shorter' && _shorter.isNotEmpty) {
      setState(() {
        _isSummary = true;
        _displayText = 'shorter';
      });
      return;
    } else if (type == 'longer' && _longer.isNotEmpty) {
      setState(() {
        _isSummary = true;
        _displayText = 'longer';
      });
      return;
    }
    Uri api;
    Map<String, String> body;
    http.Response response;
    api = Uri.parse('$apiUrl/summary/shorter-longer');
    body = {
      'original': _originalText,
      'text': _summaryText,
      'type': type,
      'deviceId': context.read<DeviceIdStore>().state
    };
    response = await http.post(
      api,
      body: body,
    );
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body); // Add this line
      if (type == 'shorter') {
        setState(() {
          _shorter = responseBody['data']['summary'];
          _displayText = 'shorter';
        });
        updateHistoryWithId(_id, 'shorter', _shorter);
      } else {
        setState(() {
          _longer = responseBody['data']['summary'];
          _displayText = 'longer';
        });
        updateHistoryWithId(_id, 'longer', _longer);
      }
      setState(() {
        _isSummary = true;
      });
    } else {
      var responseBody = jsonDecode(response.body); // Add this line
      String message = responseBody['message'] ?? 'Failed to load summary';
      //back to pop
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Summary Failed',
        text: '🚨 $message',
      );
    }
  }

  void updateHistoryWithId(String id, String key, String data) {
    context.read<HistoryStore>().update(id, key, data);
  }

  void saveToHistory() async {
    context.read<HistoryStore>().add(jsonEncode({
          'id': _id,
          'title': _titleText,
          'summary': _summaryText,
          'original': _originalText,
          'transcript': _transcriptText,
          'type': widget.type,
          'date': DateTime.now().toString(),
          'audioId': widget.audioId,
          'youtubeUrl': widget.youtubeUrl,
          'lang': widget.lang
        }));
  }

  Future<void> lunchYoutube() async {
    var url = _youtubeUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _displayTextConditon() {
    if (_displayText == 'original') {
      return _summaryText;
    } else if (_displayText == 'shorter') {
      return _shorter;
    } else if (_displayText == 'transcript') {
      return _transcriptText;
    } else {
      return _longer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        // bottom modal setting
        actions: [
          if (_isSummary)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return DraggableScrollableSheet(
                        initialChildSize: 0.4, // Initial height of the Sheet
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
                                  if (_displayText != 'original')
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _displayText = 'original';
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 43, 43, 54),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(Icons
                                                        .text_fields_rounded),
                                                  ),
                                                  const Text(
                                                    'Original Summary',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ])),
                                      ),
                                    ),
                                  if (_displayText != 'shorter')
                                    GestureDetector(
                                      onTap: () {
                                        _onFetchShorterOrLonger('shorter');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 43, 43, 54),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(Icons
                                                        .short_text_rounded),
                                                  ),
                                                  const Text(
                                                    'Make shorter',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ])),
                                      ),
                                    ),
                                  if (_displayText != 'longer')
                                    GestureDetector(
                                      onTap: () {
                                        _onFetchShorterOrLonger('longer');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 43, 43, 54),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(Icons
                                                        .line_style_rounded),
                                                  ),
                                                  const Text(
                                                    'Make longer',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ])),
                                      ),
                                    ),
                                  if (_originalType != 'transcript' &&
                                      _transcriptText.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _originalType = 'transcript';
                                        });
                                         Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 43, 43, 54),
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
                                                        Icons.transcribe),
                                                  ),
                                                  const Text(
                                                    'Show Transcript',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ])),
                                      ),
                                    ),
                                    if (_originalType == 'transcript')
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _originalType = 'original';
                                        });
                                         Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 5.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 43, 43, 54),
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
                                                        Icons.text_fields),
                                                  ),
                                                  const Text(
                                                    'Show Text',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ])),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                );
              },
              icon: const Icon(Icons.list_outlined),
            ),
        ],
      ),
      body: !_isSummary ? _loading() : _summary(),
    );
  }

  Widget _summary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Text(
            _titleText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 5,
          ),
          // now date format
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  _date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              // display type
              if (_displayText != 'original')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFD789),
                  ),
                  child: Text(
                    _displayText.toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
            ],
          ),
          if (_youtubeUrl.isNotEmpty)
            GestureDetector(
              onTap: () {
                lunchYoutube();
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Text(
                      _youtubeUrl,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFFFFD789)), // Add this line
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Summary'),
                    Tab(text: 'Original'),
                  ],
                  labelColor: const Color(0xFF14141A),
                  unselectedLabelColor: Colors.white,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFD789),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView(
                    children: [
                      TextField(
                        controller:
                            TextEditingController(text: _displayTextConditon()),
                        maxLines: null,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  // controll use original or transcript
                  // if (_transcriptText.isNotEmpty)
                  //   Positioned(
                  //     right: 10,
                  //     top: 10,
                  //     child: ElevatedButton(
                  //       onPressed: () {},
                  //       child: const Icon(Icons.timer),
                  //     ),
                  //   ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ListView(
                        children: [
                          // Text(widget.text),
                          TextField(
                            controller:
                                TextEditingController(text: _originalType == 'transcript' ? _transcriptText : _originalText),
                            maxLines: null,
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
