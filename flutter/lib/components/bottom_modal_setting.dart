import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class BottomModalSetting extends StatefulWidget {
  const BottomModalSetting({super.key});

  @override
  State<BottomModalSetting> createState() => _BottomModalSettingState();
}

class _BottomModalSettingState extends State<BottomModalSetting> {
  Future<void> _openPurchase() async {
    HapticFeedback.mediumImpact();
    final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("pro");
    debugPrint("paywallResult: $paywallResult");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282834),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return DraggableScrollableSheet(
                  initialChildSize: 0.3, // Initial height of the Sheet
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
                            GestureDetector(
                              onTap: () {
                                _openPurchase();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 5.0),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 43, 43, 54),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.star,
                                                color: Color(0xFFFFD789)),
                                          ),
                                          const Text(
                                            'Get Premium',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ])),
                              ),
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 5.0),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 43, 43, 54),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.rate_review,
                                                color: Color(0xFFFFD789)),
                                          ),
                                          const Text(
                                            'Rate Us',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ])),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
          );
        },
        icon: const Icon(Icons.settings, color: Color(0xFFFFD789)),
      ),
    );
  }
}
