import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarizeit/components/bottom_modal_setting.dart';
import 'package:sumarizeit/page/history/history_page.dart';
import 'package:sumarizeit/page/record_audio/record_audio_page.dart';
import 'package:sumarizeit/page/summary_done.dart';
import 'package:sumarizeit/page/text_summary/text_summary_page.dart';
import 'package:sumarizeit/page/youtube_summary/youtube_summary_page.dart';
import 'package:sumarizeit/store/deviceId_store.dart';
import 'package:sumarizeit/store/history_store.dart';
import 'package:sumarizeit/store/purchase_store.dart';
import 'package:sumarizeit/store/recording_store.dart';
import 'package:sumarizeit/store/saved_time_store.dart';
import 'package:sumarizeit/tutorial/tutorial_component.dart';

final _configuration =
    PurchasesConfiguration("appl_pwKTuHxkhdQZXeXPFOePdNwPakZ");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Purchases.configure(_configuration);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SavedTimeStore(),
          ),
          BlocProvider(create: (context) => HistoryStore()),
          BlocProvider(create: (context) => DeviceIdStore()),
          BlocProvider(create: (context) => RecordingStore()),
          BlocProvider(create: (context) => PurchaseStore()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sumarize It!',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              surfaceVariant: Colors.transparent,
              seedColor: const Color(0xFF282834),
              primary: const Color(0xFFFFD789),
              background: const Color(0xFF14141A),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Sumarize It!'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TutorialItem> items = [];

  final textSummaryKey = GlobalKey();
  final youtubeSummaryKey = GlobalKey();
  final recordSummaryKey = GlobalKey();
  String _authStatus = 'Unknown';

  Future<void> _tutorail() async {
    final prefs = await SharedPreferences.getInstance();
    bool doneTutorial = prefs.getBool('doneTutorial') ?? false;
    if (doneTutorial) {
      return;
    }

    initItems();
    Future.delayed(const Duration(microseconds: 200)).then((value) {
      Tutorial.showTutorial(context, items, onTutorialComplete: () {
        // Code to be executed after the tutorial ends
        // print('Tutorial is complete!');
        HapticFeedback.heavyImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YotubeSummaryPage()),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDeviceId();
    getPurchaseStatus();
    _tutorail();
    _openPurchaseFirstTime();

    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
              'We use data to track spam and monitor token usage for our GPT features. This helps us ensure the quality and security of our service. Please note that we do not use this data for advertising purposes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  void initItems() {
    items.addAll({
      TutorialItem(
        globalKey: textSummaryKey,
        color: Colors.black.withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Text Document',
          content: 'Summarize your text in a few clicks',
        ),
      ),
      TutorialItem(
        globalKey: youtubeSummaryKey,
        color: Colors.black.withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Youtube Summary',
          content: 'Paste your youtube link and summarize it in a few clicks',
        ),
      ),
      TutorialItem(
        globalKey: recordSummaryKey,
        color: Colors.black.withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Record Audio & Summarize',
          content: 'Record your audio and summarize it in a few clicks',
        ),
      ),
      // go to youtube
      TutorialItem(
        globalKey: youtubeSummaryKey,
        color: Colors.black.withOpacity(0.8),
        shapeFocus: ShapeFocus.roundedSquare,
        child: const TutorialItemContent(
          title: 'Try Youtube Summary',
          content: 'Click here to try youtube summary',
        ),
      ),
    });
  }

  Future<void> _openPurchaseFirstTime() async {
    //save to shared preference
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool doneTutorial = prefs.getBool('doneTutorial') ?? false;
    if (!doneTutorial) {
      return;
    }
    if (isFirstTime) {
      prefs.setBool('isFirstTime', false);
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
      debugPrint("paywallResult: $paywallResult");
    }
  }

  void getPurchaseStatus() async {
    context.read<PurchaseStore>().initPurchaseStore();
  }

  void getDeviceId() async {
    context.read<DeviceIdStore>().initDeviceId();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
              // Row space between
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // rounded text saved time
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD789),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: BlocBuilder<SavedTimeStore, double>(
                        builder: (context, state) {
                          return Text(
                            'Time saved: ${NumberFormat("#,##0").format(double.parse(state.toString()))} mins',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      )),
                  // profile
                  const BottomModalSetting()
                ],
              ),
              const SizedBox(height: 16),
              // large text
              const Text('Start Your Summary Here',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Card 1
                    GestureDetector(
                      key: textSummaryKey,
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
                                    color: const Color(0xFFFFD789),
                                    child: const Icon(
                                        Icons.document_scanner_rounded,
                                        color: Color.fromRGBO(45, 45, 45, 1)),
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
                      key: youtubeSummaryKey,
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
                                    color: const Color(0xFFFFD789),
                                    child: const Icon(Icons.audio_file,
                                        color: Color.fromRGBO(45, 45, 45, 1)),
                                  ),
                                ),
                              ),
                              // Text
                              const Text('Youtube',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Summarize your youtube video',
                                style: TextStyle(
                                    //color secondary
                                    color: theme.colorScheme.secondary),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Card 3
                    GestureDetector(
                      key: recordSummaryKey,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RecordAudioPage()),
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
                                    color: const Color(0xFFFFD789),
                                    child: const Icon(Icons.mic_rounded,
                                        color: Color.fromRGBO(45, 45, 45, 1)),
                                  ),
                                ),
                              ),
                              // Text
                              const Text('Record Audio',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Record your audio and summarize it',
                                style: TextStyle(
                                    //color secondary
                                    color: theme.colorScheme.secondary),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Card 4
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const RecordAudioPage()),
                        // );
                        //Alert on implementation
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Coming Soon!'),
                              content: const Text(
                                  'This feature is under development. Stay tuned!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 18, 18, 18),
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
                                    color: const Color(0xFFFFD789),
                                    child: const Icon(Icons.web_rounded,
                                        color: Color.fromRGBO(45, 45, 45, 1)),
                                  ),
                                ),
                              ),
                              // Text
                              const Text('Web Page',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Summarize your web page \n(Coming Soon!)',
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
              // History
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('History',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),

                            //view all button
                            TextButton(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryPage()),
                                );
                              },
                              child: const Text('View All'),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // History list
                      BlocBuilder<HistoryStore, List<Map<String, dynamic>>>(
                          builder: (context, state) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.length >= 3 ? 3 : state.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SummaryDone(
                                      text: state[index]['summary'],
                                      type: state[index]['type'],
                                      title: state[index]['title'],
                                      done: true,
                                      historyId: state[index]['id'],
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(state[index]['title']),
                                subtitle: Text(
                                    '${state[index]['summary'].toString().length >= 50 ? state[index]['summary'].toString().substring(0, 50) : state[index]['summary'].toString()}...'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            );
                          },
                        );
                      })
                    ],
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
