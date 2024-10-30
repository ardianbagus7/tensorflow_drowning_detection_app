import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widget/custom_button.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  goToNextScreen() {
    context.go("/home");
  }

  next() {
    if (currentIndex >= 0) {
      goToNextScreen();
      return;
    }
    currentIndex += 1;

    _pageController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {});
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: <Widget>[
          // const SizedBox(height: 20),
          // Padding(
          //   padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
          //   child: Row(
          //     children: [
          //       // const LocalizationWidget(),
          //       const Spacer(),
          //       InkWell(
          //         onTap: () {
          //           goToNextScreen();
          //         },
          //         child: const Text(
          //           "Lewati",
          //           style: TextStyle(
          //             color: Colors.grey,
          //             fontSize: 18,
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              onPageChanged: (int page) {
                setState(() {
                  currentIndex = page;
                });
              },
              controller: _pageController,
              children: <Widget>[
                makePage(
                  image: "assets/images/intro_1.png",
                  title: "Drowning Detection",
                  content:
                      "Selamat Datang, silahkan tekan mulai untuk melanjutkan!",
                ),
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: _buildIndicator(),
          // ),
          // const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: CustomButton(
              width: double.infinity,
              onPressed: () {
                next();
              },
              text: "Mulai",
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget makePage({
    required String image,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: image.isEmpty
                  ? const Placeholder()
                  : Image.asset(
                      image,
                    ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          if (title.isNotEmpty) ...[
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          if (content.isNotEmpty)
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 30 : 6,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 4; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }
}
