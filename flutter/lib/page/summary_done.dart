import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sumarizeit/main.dart';
import 'package:sumarizeit/store/deviceId_store.dart';
import 'package:sumarizeit/store/history_store.dart';
import 'package:sumarizeit/store/purchase_store.dart';
import 'package:sumarizeit/store/saved_time_store.dart';
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
      this.historyId = ''});

  final String text;
  final String type;
  final String title;
  final String pathAudioFile;
  final String audioId;
  final double audioDuration;
  final bool done;
  final String historyId;
  final String youtubeUrl;

  @override
  State<SummaryDone> createState() => _SummaryDoneState();
}

class _SummaryDoneState extends State<SummaryDone>
    with SingleTickerProviderStateMixin {
  bool _isSummary = false;
  String _summaryText = '';
  String _originalText = '';
  String _transcriptText = '';
  String _titleText = '';
  late TabController _tabController;
  final ThemeData theme = ThemeData();
  //init
  @override
  void initState() {
    super.initState();
    _onSummary();
    _tabController = TabController(length: 2, vsync: this);
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
    // var formattedTime = time.toStringAsFixed(2);
    // final prefs = await SharedPreferences.getInstance();
    // final timeSaved = prefs.getDouble('timeSaved') ?? 0;
    // prefs.setDouble('timeSaved', timeSaved + double.parse(formattedTime));
    final timeBloc = context.read<SavedTimeStore>();
    timeBloc.increment(time);
  }

  Future _getHistoryById() async {
    context.read<HistoryStore>().state.forEach((element) {
      if (element['id'] == widget.historyId) {
        setState(() {
          _summaryText = element['summary'];
          _originalText = element['original'];
          _titleText = element['title'];
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
          _summaryText = history[i]['summary'];
          _originalText = history[i]['original'];
          _titleText = history[i]['title'];
          _transcriptText = history[i]['transcript'];
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
          history[i]['youtubeUrl'] == widget.youtubeUrl) {
        setState(() {
          _summaryText = history[i]['summary'];
          _originalText = history[i]['original'];
          _titleText = history[i]['title'];
          _transcriptText = history[i]['transcript'];
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
      body = {'url': widget.text, 'deviceId': deviceId};
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
          title: 'This video has no transcript. feature on beta, please contact us if you need this feature',
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

  void saveToHistory() async {
    context.read<HistoryStore>().add(jsonEncode({
          'id': DateTime.now().toString(),
          'title': _titleText,
          'summary': _summaryText,
          'original': _originalText,
          'transcript': _transcriptText,
          'type': widget.type,
          'date': DateTime.now().toString(),
          'audioId': widget.audioId,
          'youtubeUrl': widget.youtubeUrl,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: !_isSummary ? _loading() : _summary(),
    );
  }

  Widget _summary() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Text(
            _titleText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
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
                        controller: TextEditingController(text: _summaryText),
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
                                TextEditingController(text: _originalText),
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
