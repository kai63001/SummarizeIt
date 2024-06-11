import 'dart:convert';

import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';
import 'package:sumarizeit/page/summary_done.dart';

class WebPageSummaryPage extends StatefulWidget {
  const WebPageSummaryPage({super.key});

  @override
  State<WebPageSummaryPage> createState() => _WebPageSummaryPageState();
}

class _WebPageSummaryPageState extends State<WebPageSummaryPage> {
  final TextEditingController _controller = TextEditingController();
  String dataToSummary = '';

  @override
  void initState() {
    super.initState();
  }

  void _fetchDataOnlyBodyAndText(String url) async {
    var parser = await Chaleno().load(url);
    String? body = '';
    //check if url is wikipedia
    if (url.contains('wikipedia')) {
      body = parser!.querySelector('div.mw-content-ltr').text;
    } else {
      body = parser!.querySelector('article').text;
    }

    //remove all html tags
    body = body!.replaceAll(RegExp(r'<[^>]*>'), '');

    debugPrint('body: ${body.length}');
    if (body.isEmpty) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryDone(
          text: body as String,
          type: 'text-summary',
          youtubeUrl: url,
        ),
      ),
      (Route<dynamic> route) => route.isFirst,
    );

    // return http.get(Uri.parse(url)).then((response) {
    //   if (response.statusCode == 200) {
    //     final body = response.body;
    //     // Extract the content within the <body> tags
    //     final bodyTagContent = RegExp(r'<body[^>]*>(.*?)<\/body>', dotAll: true)
    //             .firstMatch(body)
    //             ?.group(1) ??
    //         '';

    //     // Remove all HTML tags
    //     final textOnly = bodyTagContent.replaceAll(RegExp(r'<[^>]*>'), '');

    //     // Remove extra whitespace and join the text
    //     final text = textOnly
    //         .split('\n')
    //         .map((line) => line.trim())
    //         .where((line) => line.isNotEmpty)
    //         .join(' ');

    //     debugPrint('text: ${text.length}');
    //     setState(() {
    //       dataToSummary = text;
    //     });

    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => SummaryDone(
    //           text: dataToSummary,
    //           type: 'text-summary',
    //           youtubeUrl: url,
    //         ),
    //       ),
    //       (Route<dynamic> route) => route.isFirst,
    //     );
    //   } else {
    //     throw Exception('Failed to load data');
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Page Summary'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: urlGetData(),
        ),
      ),
    );
  }

  ListView urlGetData() {
    return ListView(
      children: [
        const SizedBox(height: 16),
        // large text
        // Get Primmium
        const SizedBox(height: 20),
        // Text Field
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Enter Web URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        // Submit Button
        ElevatedButton(
            onPressed: () {
              _fetchDataOnlyBodyAndText(_controller.text);
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 13),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: const Text('Submit')),
      ],
    );
  }
}
