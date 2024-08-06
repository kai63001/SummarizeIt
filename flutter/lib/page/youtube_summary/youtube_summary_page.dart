import 'dart:convert';

import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarizeit/page/summary_done.dart';
import 'package:sumarizeit/tutorial/tutorial_component.dart';
import 'package:youtube_caption_scraper/youtube_caption_scraper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../contant/contants.dart';
import 'package:http/http.dart' as http;

class YotubeSummaryPage extends StatefulWidget {
  const YotubeSummaryPage({super.key});

  @override
  State<YotubeSummaryPage> createState() => _YotubeSummaryPageState();
}

class _YotubeSummaryPageState extends State<YotubeSummaryPage> {
  final TextEditingController _controller = TextEditingController();
  String _lang = 'en';
  bool _isGetYoutubeData = false;
  Map<String, dynamic> _youtubeData = {
    'title': '',
    'thumbnail': '',
    'lang': ['en']
  };

  List<TutorialItem> items = [];

  final textSummaryKey = GlobalKey();
  final summitKey = GlobalKey();
  final summarizeButtonKey = GlobalKey();

  void initItems() {
    items.addAll({
      TutorialItem(
        globalKey: textSummaryKey,
        color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Youtube URL',
          content: 'Paste your youtube link and summarize it in a few clicks',
        ),
      ),
      TutorialItem(
        globalKey: summitKey,
        color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Summarize Button',
          content: 'Click here to show youtube summary data',
        ),
      ),
    });
  }

  Future<void> _tutorail() async {
    final prefs = await SharedPreferences.getInstance();
    bool doneTutorial = prefs.getBool('doneTutorial') ?? false;
    if (doneTutorial) {
      return;
    }

    initItems();
    Future.delayed(const Duration(microseconds: 200)).then((value) {
      Tutorial.showTutorial(context, items, onTutorialComplete: () {
        _controller.text = 'https://youtu.be/8jPQjjsBbIc?si=6xK5poIGDKm5FWtn';
        // Code to be executed after the tutorial ends
        // print('Tutorial is complete!');
        HapticFeedback.heavyImpact();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryDone(
              text: _controller.text,
              type: 'youtube-summary',
              title:
                  'How to stay calm when you know you\'ll be stressed | Daniel Levitin | TED',
              youtubeUrl: _controller.text,
              tutorial: true,
              lang: 'en',
            ),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _tutorail();
  }

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

    String? youtubeId = youtubeUrlPattern.firstMatch(youtubeUrl)!.group(5);

    // Fetch caption tracks – these are objects containing info like
    // base url for the caption track and language code.
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Please wait',
      text: 'Getting youtube data',
      disableBackBtn: true,
    );

    var yt = YoutubeExplode();

    var trackManifest = await yt.videos.closedCaptions.getManifest(youtubeId);

    // debugPrint('trackManifest: $trackManifest');

    List<String> languageSupoort = [];
    List<String> languageCode = [
      'af',
      'am',
      'ar',
      'az',
      'bn',
      'bg',
      'my',
      'ca',
      'zh-Hans',
      'zh-Hant',
      'hr',
      'cs',
      'da',
      'nl',
      'en',
      'en-US',
      'en-GB',
      'et',
      'fil',
      'fi',
      'fr',
      'de',
      'el',
      'gu',
      'iw',
      'hi',
      'hu',
      'is',
      'id',
      'it',
      'ja',
      'kn',
      'kk',
      'km',
      'ko',
      'lo',
      'lv',
      'lt',
      'ms',
      'ml',
      'mr',
      'mn',
      'ne',
      'no',
      'fa',
      'pl',
      'pt',
      'pa',
      'ro',
      'ru',
      'sr',
      'si',
      'sk',
      'sl',
      'es',
      'sw',
      'sv',
      'ta',
      'te',
      'th',
      'tr',
      'uk',
      'ur',
      'vi',
      'cy'
    ];

    for (var lang in languageCode) {
      var languages = trackManifest.getByLanguage(lang);
      if (languages.length > 0) {
        languageSupoort.add(lang);
      }
    }

    if (languageSupoort.length == 0) {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'This video does not have any subtitle',
      );
      return;
    }
    //get Language support
    // var languages = trackManifest.getByLanguage('ko');

    //get title duration and thumbnail
    var video = await yt.videos.get(youtubeId);

    // List<ClosedCaptionTrackInfo> trackInfo = trackManifest.getByLanguage('en');

    // var track = await yt.videos.closedCaptions.get(trackInfo[0]);
    // // get all the caption merged into one
    // var caption = track.captions.map((e) => e.text).join(' ');
    // debugPrint('caption: $caption');

    // debugPrint('track: $track');
    List<String> sortLangEnFirst(List<String> lang) {
      if (lang.length > 0) {
        if (lang.contains('en')) {
          lang.remove('en');
          lang.insert(0, 'en');
        }
      }
      return lang;
    }

    setState(() {
      _isGetYoutubeData = true;
      _youtubeData = {
        'title': video.title,
        'thumbnail': video.thumbnails.standardResUrl,
        'lang': sortLangEnFirst(languageSupoort),
        'duration': video.duration?.inMinutes.toDouble()
      };
    });

    Navigator.pop(context);
    // final response = await http.get(
    //   Uri.parse('$apiUrl/summary/get-youtube-data?url=$youtubeUrl'),
    // );

    // if (response.statusCode == 200) {
    //   var responseBody = jsonDecode(response.body);
    //   setState(() {
    //     _isGetYoutubeData = true;
    //     _youtubeData = responseBody['data'];
    //   });
    //   if (_youtubeData['lang'].length > 0) {
    //     _lang = _youtubeData['lang'].contains('en')
    //         ? 'en'
    //         : _youtubeData['lang'][0];
    //   }
    // } else {
    //   throw Exception('Failed to load summary');
    // }
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
        if (_youtubeData['thumbnail'] != null)
          Image.network(_youtubeData['thumbnail']),
        const SizedBox(height: 20),
        Text(
          _youtubeData['title'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                //bottom sheet select language
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return DraggableScrollableSheet(
                        initialChildSize: 0.8, // Initial height of the Sheet
                        minChildSize: 0.1, // Minimum height of the Sheet
                        maxChildSize: 1, // Maximum height of the Sheet
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Container(
                              color: const Color(0xFF14141A),
                              child: Column(
                                children: [
                                  // Custom drag handle
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    height: 5,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[
                                          300], // Change this to your desired color
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    children: [
                                      //loop for language
                                      for (var lang in _youtubeData['lang'])
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              HapticFeedback.heavyImpact();
                                              setState(() {
                                                _lang = lang;
                                              });
                                              Navigator.pop(context);
                                            },
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    vertical: 12.5),
                                              ),
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            child: Text(lang.toUpperCase()),
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12.5),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: Text(_lang.toUpperCase()),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                key: summarizeButtonKey,
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryDone(
                        text: _controller.text,
                        type: 'youtube-summary',
                        title: _youtubeData['title'],
                        youtubeUrl: _controller.text,
                        lang: _lang,
                        audioDuration: _youtubeData['duration'],
                      ),
                    ),
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 13),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text('Summarize'),
              ),
            ),
            // cancel button with icon x
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                setState(() {
                  _isGetYoutubeData = false;
                  _youtubeData = {'title': '', 'thumbnail': '', 'lang': ''};
                  _controller.clear();
                });
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12.5),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: const Icon(Icons.close),
            ),
          ],
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
          key: textSummaryKey,
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Enter Youtube URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        // Submit Button
        ElevatedButton(
            key: summitKey,
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
