import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarizeit/page/text_summary/text_summary_page.dart';
import 'package:sumarizeit/page/youtube_summary/youtube_summary_page.dart';
import 'package:sumarizeit/purchase/purchase_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          surfaceVariant: Colors.transparent,
          seedColor: const Color(0xFF282834),
          primary: const Color(0xFFFFD789),
          background: const Color(0xFF14141A),
          // ···
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sumarize It!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();

    return Scaffold(
        appBar: null,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              // large text
              const Text('Start Your Summary Journey Here',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Get Primmium
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PurchaseModal()));
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text('Get Premium'),
                  ],
                ),
              ),
              // Grid view
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Card 1
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TextSummaryPage()),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // logo in a circle
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.blue,
                                    child: const Icon(
                                        Icons.document_scanner_rounded),
                                  ),
                                ),
                              ),
                              // Text
                              const Text('Text Document',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Summarize your text in a few clicks',
                                style: TextStyle(
                                    //color secondary
                                    color: theme.colorScheme.secondary),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Card 2
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const YotubeSummaryPage()),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // logo in a circle
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.blue,
                                    child: const Icon(Icons.audio_file),
                                  ),
                                ),
                              ),
                              // Text
                              const Text('Youtube',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Summarize your youtube video in a few clicks',
                                style: TextStyle(
                                    //color secondary
                                    color: theme.colorScheme.secondary),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Time Saved',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: theme.colorScheme.secondary)),
                      const Text('0 minutes',
                          style: TextStyle(
                              //color secondary
                              fontSize: 18,
                              color: Colors.white)),
                    ],
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
