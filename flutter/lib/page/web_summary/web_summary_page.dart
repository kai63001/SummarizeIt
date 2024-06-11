import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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
    //validate is url
    if (!Uri.parse(url).isAbsolute) {
      QuickAlert.show(
          context: context,
          title: 'Invalid URL',
          text: 'Please enter a valid URL',
          type: QuickAlertType.error);
      return;
    }

    var parser = await Chaleno().load(url);
    String? body = '';
    //check if url is wikipedia
    if (url.contains('wikipedia')) {
      body = parser!.querySelector('div.mw-content-ltr').text;
    } else {
      body = parser!.querySelector('article').text;
    }

    body ??= parser.querySelector('body').text;

    body = body!.replaceAll(RegExp(r'<[^>]*>'), '');
    // Remove all script tags and content
    body =
        body.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    // Remove all style tags and content
    body =
        body.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
    // Remove all HTML comments
    body = body.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    // Remove all new lines
    body = body.replaceAll(RegExp(r'\n'), '');
    // Remove all tabs
    body = body.replaceAll(RegExp(r'\t'), '');
    // Remove all multiple spaces
    body = body.replaceAll(RegExp(r' +'), ' ');
    // Remove CSS blocks
    RegExp cssPattern =
        RegExp(r'@media[^{]*\{[^}]*\}|\.[^{]*\{[^}]*\}|\#[^{]*\{[^}]*\}');
    body = body.replaceAll(cssPattern, '');

    // Remove HTML tags
    RegExp htmlPattern =
        RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    body = body.replaceAll(htmlPattern, '');

    // Remove multiple spaces and new lines
    body = body.replaceAll(RegExp(r'\s+'), ' ').trim();

    debugPrint('body: ${body.length}');
    if (body.isEmpty) {
      QuickAlert.show(
          context: context,
          title: 'Invalid URL',
          text: 'Please enter a valid URL',
          type: QuickAlertType.error);
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
