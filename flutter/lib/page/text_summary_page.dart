import 'package:flutter/material.dart';

class TextSummaryPage extends StatefulWidget {
  const TextSummaryPage({super.key});

  @override
  State<TextSummaryPage> createState() => _TextSummaryPageState();
}

class _TextSummaryPageState extends State<TextSummaryPage> {
  final TextEditingController _controller = TextEditingController();
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharacterCount);
    _controller.dispose();
    super.dispose();
  }

 void _updateCharacterCount() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Sumarzation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  Container(
                    //border
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 5.0),
                      child: TextField(
                        controller: _controller,
                        maxLines: 10000,
                        decoration: const InputDecoration(
                            hintText: 'Enter your text here',
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Text(
                      '$_characterCount characters',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // button
          Padding(
            padding:
                const EdgeInsets.only(bottom: 30.0, left: 20.0, right: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Set the radius to 10
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Summarize',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
