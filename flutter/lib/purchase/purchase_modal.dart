import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PurchaseModal extends StatefulWidget {
  const PurchaseModal({super.key});

  @override
  State<PurchaseModal> createState() => _PurchaseModalState();
}

class _PurchaseModalState extends State<PurchaseModal> {
  int selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    //data pricing array
    var dataPricing = [
      {
        'title': 'Yealy Plan',
        'price': '\$ 0.99 / week',
        'mostPopular': true,
      },
      {
        'title': 'Monthly Plan',
        'price': '\$ 0.99 / week',
        'mostPopular': false,
      },
      {
        'title': 'Weekly Plan',
        'price': '\$ 0.99 / week',
        'mostPopular': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF14141A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              //close button
              Row(
                //between
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Restore',
                    style: TextStyle(
                        color: Color.fromARGB(255, 204, 166, 89),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => {
                      Navigator.pop(context),
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // icon 5 star
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(
                    Icons.star,
                    size: 30,
                    color: Color.fromARGB(255, 255, 218, 7),
                  );
                }),
              ),
              // RichText boot your summary
              const SizedBox(
                height: 20,
              ),
              RichText(
                //center
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Go Premium : Take Your Summaries to the ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Next Level',
                      style: TextStyle(
                        color: Color(0xFFFFD789),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // features unlock with icon check circle and wording at the right
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenSize.width * 0.2),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFFFD789),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Summarize Youtube Videos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFFFD789),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Unlocked All Features',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFFFD789),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Unlimited summaries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 3 column selection per year per month per week
              const SizedBox(
                height: 20,
              ),
              // columns selection and click to selectit
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  // loop via dataPricing
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataPricing.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            key: ValueKey(i),
                            onTap: () => {
                              setState(() {
                                selectedPlan = i;
                              }),
                            },
                            child: SizedBox(
                              height: 50,
                              child: Stack(
                                fit: StackFit.expand,
                                clipBehavior: Clip.none,
                                alignment: AlignmentDirectional.topCenter,
                                children: [
                                  // most popular on the right top
                                  Container(
                                    //padding
                                    // border
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: selectedPlan == i
                                            ? const Color(0xFFFFD789)
                                            : Colors.grey,
                                        width: selectedPlan == i ? 2 : 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Row(
                                        //between
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              dataPricing[i]['title'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              )),
                                          Text(
                                            dataPricing[i]['price'] as String,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (dataPricing[i]['mostPopular'] as bool)
                                    Positioned(
                                      right: 10,
                                      top: -11,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: selectedPlan == i
                                              ? const Color(0xFFFFD789)
                                              : Colors.grey,
                                        ),
                                        child: const Text(
                                          'Most Popular',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
