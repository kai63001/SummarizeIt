import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contant/contants.dart';
import 'dart:convert';

class SummaryDone extends StatefulWidget {
  const SummaryDone({super.key, required this.text, required this.type});

  final String text;
  final String type;

  @override
  State<SummaryDone> createState() => _SummaryDoneState();
}

class _SummaryDoneState extends State<SummaryDone>
    with SingleTickerProviderStateMixin {
  bool _isSummary = false;
  String _summaryText = '';
  String _originalText = '';
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

  void alertSaveTime(time) {
    var formattedTime = time.toStringAsFixed(2);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Time Saved',
      text: 'You saved $formattedTime minutes',
    );
    timeSavedSaveToStorage(time);
  }

  void timeSavedSaveToStorage(time) async {
    var formattedTime = time.toStringAsFixed(2);
    final prefs = await SharedPreferences.getInstance();
    final timeSaved = prefs.getDouble('timeSaved') ?? 0;
    prefs.setDouble('timeSaved', timeSaved + double.parse(formattedTime));
  }

  Future _onSummary() async {
    Uri api;
    Map<String, String> body;
    if (widget.type == 'text-summary') {
      api = Uri.parse('$apiUrl/summary/text-summary');
      body = {'text': widget.text};
    } else {
      api = Uri.parse('$apiUrl/summary/youtube-summary');
      body = {'url': widget.text};
    }

    final response = await http.post(
      api,
      body: body,
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body); // Add this line
      if (widget.type == 'text-summary') {
        setState(() {
          _summaryText = responseBody['data']['summary']; // Change this line
          _originalText = widget.text;
          _isSummary = true;
          // parse to duble
          double time = double.parse(responseBody['data']['time'].toString());
          alertSaveTime(time);
        });
      } else {
        setState(() {
          _summaryText = responseBody['data']['summary']; // Change this line
          _originalText = responseBody['data']['text'];
          _isSummary = true;
          alertSaveTime(responseBody['data']['time']);
        });
      }
    } else {
      //back to pop
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Summary Failed',
        text: '🚨 Transcript is disabled on this video',
      );
    }
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
                        controller: TextEditingController(text: _originalText),
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
