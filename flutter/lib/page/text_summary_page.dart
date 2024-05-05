import 'package:flutter/material.dart';

class TextSummaryPage extends StatefulWidget {
  const TextSummaryPage({super.key});

  @override
  State<TextSummaryPage> createState() => _TextSummaryPageState();
}

class _TextSummaryPageState extends State<TextSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Sumarzation'),
      ),
      body: const Column(
        children: [
// multi line text field
          TextField(
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Enter your text here',
            ),
          ),
        ],
      ),
    );
  }
}
