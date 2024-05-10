import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../contant/contants.dart';
import 'package:http/http.dart' as http;

class YotubeSummaryPage extends StatefulWidget {
  const YotubeSummaryPage({super.key});

  @override
  State<YotubeSummaryPage> createState() => _YotubeSummaryPageState();
}

class _YotubeSummaryPageState extends State<YotubeSummaryPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isGetYoutubeData = false;
  Map<String, dynamic> _youtubeData = {
    'title': '',
    'thumbnail': '',
  };

  Future<void> _submitYoutubeUrl() async {
    HapticFeedback.mediumImpact();
    // regex ((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?
    final youtubeUrl = _controller.text;
    final youtubeUrlPattern = RegExp(
        r'((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?');
    if (_controller.text.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (!youtubeUrlPattern.hasMatch(youtubeUrl)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please enter a valid youtube URL',
      );
      return;
    }
    final response = await http.get(
      Uri.parse('$apiUrl/summary/get-youtube-data?url=$youtubeUrl'),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      setState(() {
        _isGetYoutubeData = true;
        _youtubeData = responseBody['data'];
      });
    } else {
      throw Exception('Failed to load summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Youtube Summary'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _isGetYoutubeData ? showYoutubeData() : urlGetData(),
        ),
      ),
    );
  }

  ListView showYoutubeData() {
    return ListView(
      children: [
        const SizedBox(height: 20),
        Image.network(_youtubeData['thumbnail']),
        const SizedBox(height: 20),
        Text(
          _youtubeData['title'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
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
          child: const Text('Summarize'),
        ),
      ],
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
            hintText: 'Enter Youtube URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        // Submit Button
        ElevatedButton(
            onPressed: () {
              _submitYoutubeUrl();
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
