import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../contant/contants.dart';
import 'dart:convert';

class SummaryDone extends StatefulWidget {
  const SummaryDone({super.key, required this.text});

  final String text;

  @override
  State<SummaryDone> createState() => _SummaryDoneState();
}

class _SummaryDoneState extends State<SummaryDone>
    with SingleTickerProviderStateMixin {
  bool _isSummary = false;
  String _summaryText = '';
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
  }

  Future _onSummary() async {
    final response = await http.post(
      Uri.parse('$apiUrl/summary/text-summary'),
      body: {'text': widget.text},
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body); // Add this line
      setState(() {
        _summaryText = responseBody['data']['summary']; // Change this line
        _isSummary = true;
      });
    } else {
      throw Exception('Failed to load summary');
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
                        controller: TextEditingController(text: widget.text),
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
