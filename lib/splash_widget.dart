import 'dart:async'; // Import dart:async for Timer
import 'package:crmapp/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_widget.dart'; // Make sure this path matches your HomeWidget location

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  final PageController pageController = PageController(initialPage: 0);
  Timer? _timer; // Timer for auto-sliding
  int _currentPage = 0;
  final int _numPages = 3; // Total number of slides

  @override
  void initState() {
    super.initState();
    // Start auto-sliding
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _numPages - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Restart slides or navigate away
        // Navigate to HomeWidget after last slide
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignUpWidget()));
      }
      pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            PageView(
              controller: pageController,
              scrollDirection: Axis.horizontal,
              children: [
                buildPageViewContent(
                  context: context,
                  imageName:
                      'assets/images/Locate_logo_1__2_-removebg-preview-transformed_1.png',
                  title: 'FHAIDA CRM',
                  mainText: 'Where Every \nInteraction Becomes an Opportunity!',
                  subText: 'Fully Automated, Fully Efficient!',
                ),
                buildPageViewContent(
                  context: context,
                  imageName: 'assets/images/logo.png',
                  title: 'FHAIDA CRM',
                  mainText: 'Every Click Saves Time',
                  subText:
                      'Streamline Your Processes with Our Intuitive Dashboard, Customizable to Your Unique Business Needs',
                ),
                buildPageViewContent(
                  context: context,
                  imageName: 'assets/images/logo.png',
                  title: 'FHAIDA CRM',
                  mainText: 'Dive Into Fhaida CRM',
                  subText:
                      'Discover a World of Organized Contacts, Efficient Lead Tracking, and Personalized Client Interactions',
                ),
              ],
            ),
            Positioned(
              bottom: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    List.generate(_numPages, (index) => buildDot(index: index)),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 40,
              right: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(FontAwesomeIcons.longArrowAltLeft, size: 14),
                    onPressed: () {
                      pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.longArrowAltRight, size: 14),
                    onPressed: () {
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageViewContent(
      {required BuildContext context,
      required String imageName,
      required String title,
      required String mainText,
      required String subText}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Image.asset(imageName, width: 50, height: 50, fit: BoxFit.cover),
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontSize: 24, fontFamily: 'Brazila')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(mainText,
                  style: TextStyle(fontSize: 38, fontFamily: 'Brazila')),
              SizedBox(height: 40),
              Text(subText,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Brazila',
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
