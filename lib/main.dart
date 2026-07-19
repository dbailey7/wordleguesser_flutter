import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding_screen.dart';
import 'screens/wordle_screen.dart';
import 'theme.dart';
import 'wordle_notifier.dart';

const _prefsKeyOnboardingDone = 'onboarding_done';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = !(prefs.getBool(_prefsKeyOnboardingDone) ?? false);
  runApp(WordleGuesserApp(showOnboarding: isFirstRun));
}

class WordleGuesserApp extends StatefulWidget {
  final bool showOnboarding;
  const WordleGuesserApp({super.key, required this.showOnboarding});

  @override
  State<WordleGuesserApp> createState() => _WordleGuesserAppState();
}

class _WordleGuesserAppState extends State<WordleGuesserApp> {
  late bool _showOnboarding = widget.showOnboarding;
  final _notifier = WordleNotifier();

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = !(prefs.getBool(_prefsKeyOnboardingDone) ?? false);
    await prefs.setBool(_prefsKeyOnboardingDone, true);
    if (firstTime) {
      _notifier.loadTutorialExample();
    }
    setState(() => _showOnboarding = false);
  }

  void _showHelp() {
    setState(() => _showOnboarding = true);
  }

  Future<void> _resetDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyOnboardingDone, false);
    _notifier.clearAll();
    setState(() => _showOnboarding = true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WordleNotifier>.value(
      value: _notifier,
      child: MaterialApp(
        title: 'Wordle Guesser',
        debugShowCheckedModeBanner: false,
        theme: wordleGuesserTheme(),
        home: _showOnboarding
            ? OnboardingScreen(onFinished: _finishOnboarding)
            : WordleScreen(onShowHelp: _showHelp, onResetDemo: _resetDemo),
      ),
    );
  }
}
