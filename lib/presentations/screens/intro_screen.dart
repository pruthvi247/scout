import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scout/handlers/login_checker.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> _quotes = [];
  final List<String> _images = [
    'intro-images/vnr1.jpeg',
    'intro-images/vnr2.jpeg',
    'intro-images/vnr3.jpg',
    'intro-images/vnr4.jpeg',
    'intro-images/vnr5.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final quotesString = await rootBundle.loadString('intro-images/quotes.txt');
    setState(() {
      _quotes =
          quotesString.split('\n').where((q) => q.trim().isNotEmpty).toList();
    });
  }

  void _onSkip() async {
    final isLoggedIn = await LoginChecker.isLoggedIn();
    if (isLoggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onGetStarted() async {
    final isLoggedIn = await LoginChecker.isLoggedIn();
    if (isLoggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _quotes.length == 5
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: 5,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                _images[index],
                                width: double.infinity,
                                height: size.height * 0.6,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                _quotes[index],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (index == 4)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: ElevatedButton(
                                  onPressed: _onGetStarted,
                                  child: const Text('Get Started'),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _onSkip,
                child: const Text('Skip'),
              ),
            ),
            // Navigation indicator (dots)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.deepPurple
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // Next arrow
            if (_currentPage < 4)
              Positioned(
                bottom: 24,
                right: 24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 28),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
