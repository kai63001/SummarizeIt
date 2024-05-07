import 'package:flutter/material.dart';

class TextSummaryDone extends StatefulWidget {
  const TextSummaryDone({super.key, required this.text});

  final String text;

  @override
  State<TextSummaryDone> createState() => _TextSummaryDoneState();
}

class _TextSummaryDoneState extends State<TextSummaryDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(widget.text),
      ),
    );
  }
}
