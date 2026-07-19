import 'package:flutter/material.dart';

import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _pageCount = 4;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: onboardingBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: const [
                    _PageOne(),
                    _PageTwo(),
                    _PageThree(),
                    _PageFour(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (i) {
                  final active = i == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: active ? 10 : 8,
                      height: active ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? wordleGreen
                            : wordleGray.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wordleGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLastPage ? widget.onFinished : _next,
                  child: Text(
                    _isLastPage ? 'Enter Clues' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: _isLastPage
                    ? null
                    : Center(
                        child: TextButton(
                          onPressed: widget.onFinished,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: wordleGray, fontSize: 14),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'WORDLE\nGUESSER',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 46 / 40,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stareTile('S', tileNeutral),
            const SizedBox(width: 6),
            _stareTile('T', wordleYellow),
            const SizedBox(width: 6),
            _stareTile('A', tileNeutral),
            const SizedBox(width: 6),
            _stareTile('R', wordleGreen),
            const SizedBox(width: 6),
            _stareTile('E', tileNeutral),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Your Wordle Assistant',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Stuck on today's puzzle? Enter what you know and it searches "
          '240,000+ words to find your best next guesses.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: wordleGray, height: 24 / 16),
        ),
      ],
    );
  }

  Widget _stareTile(String letter, Color color) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PageTwo extends StatelessWidget {
  const _PageTwo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'The Three Clues',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        _ClueCard(
          color: wordleGreen,
          letter: 'G',
          title: 'Green — Right letter, right spot',
          detail: 'Right position — locked in.',
        ),
        SizedBox(height: 8),
        _ClueCard(
          color: wordleYellow,
          letter: 'Y',
          title: 'Yellow — Right letter, wrong spot',
          detail: 'In the word, but wrong position.',
        ),
        SizedBox(height: 8),
        _ClueCard(
          color: tileNeutral,
          letter: 'X',
          title: 'Gray — Letter not in the word',
          detail: 'Not in the word at all.',
        ),
      ],
    );
  }
}

class _ClueCard extends StatelessWidget {
  final Color color;
  final String letter;
  final String title;
  final String detail;

  const _ClueCard({
    required this.color,
    required this.letter,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: onboardingCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: onboardingSubtleText,
                    height: 18 / 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageThree extends StatelessWidget {
  const _PageThree();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Entering Your Clues',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Three quick steps after each Wordle guess:',
            style: TextStyle(fontSize: 15, color: onboardingSubtleText),
          ),
          SizedBox(height: 16),
          _StepCard(
            step: '1',
            color: wordleGreen,
            title: 'Type your guessed word',
            detail:
                'Enter the 5-letter word you just played in Wordle into the letter boxes.',
          ),
          SizedBox(height: 8),
          _StepCard(
            step: '2',
            color: wordleYellow,
            title: 'Tap tiles to set colors',
            detail:
                "Tap each tile to cycle its color — Gray, Yellow, or Green — to match Wordle's result.",
          ),
          SizedBox(height: 8),
          _StepCard(
            step: '3',
            color: tileNeutral,
            title: 'Tap "Get Guesses"',
            detail:
                'Wordle Guesser will show a ranked list of the best words to try next.',
          ),
          SizedBox(height: 16),
          Text(
            'Repeat for each guess until you crack the puzzle!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xCC538D4E), height: 20 / 14),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final Color color;
  final String title;
  final String detail;

  const _StepCard({
    required this.step,
    required this.color,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: onboardingCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: onboardingSubtleText,
                    height: 18 / 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageFour extends StatelessWidget {
  const _PageFour();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: wordleGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            '✓',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "You're Ready!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'After each Wordle guess, enter the color results here. Tap Get '
          'Guesses for a ranked list of the best candidates to try next.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: wordleGray, height: 24 / 16),
        ),
        const SizedBox(height: 20),
        Text(
          'Tap ❓ anytime to revisit these instructions.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: wordleGreen.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}
