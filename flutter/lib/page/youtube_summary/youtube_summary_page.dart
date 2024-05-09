import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class YotubeSummaryPage extends StatefulWidget {
  const YotubeSummaryPage({super.key});

  @override
  State<YotubeSummaryPage> createState() => _YotubeSummaryPageState();
}

class _YotubeSummaryPageState extends State<YotubeSummaryPage> {
  final TextEditingController _controller = TextEditingController();

  void _submitYoutubeUrl() {
    // regex ((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?
    final youtubeUrl = _controller.text;
    final youtubeUrlPattern = RegExp(
        r'((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?');
    if (_controller.text.isEmpty) {
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
    print('Youtube URL: $youtubeUrl');
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
          child: ListView(
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
          ),
        ),
      ),
    );
  }
}
