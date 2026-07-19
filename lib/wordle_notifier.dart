import 'package:flutter/foundation.dart';

import 'wordle_repository.dart';

enum InputMode { none, green, yellow, black }

class WordleNotifier extends ChangeNotifier {
  final WordleRepository _repository = WordleRepository();

  int wordLength = 5;
  Map<int, String> greenLetters = {};
  Map<int, String> yellowLetters = {};
  Set<String> blackLetters = {};
  InputMode activeInput = InputMode.none;
  int? selectedPosition;
  List<WordResult> results = [];
  bool isLoading = false;
  bool hasQueried = false;
  bool showTutorialBanner = false;

  void loadTutorialExample() {
    wordLength = 5;
    greenLetters = {4: 'r'};
    yellowLetters = {2: 't', 3: 'a'};
    blackLetters = {'s', 'e'};
    activeInput = InputMode.none;
    selectedPosition = null;
    results = [];
    isLoading = false;
    hasQueried = false;
    showTutorialBanner = true;
    notifyListeners();
  }

  void dismissTutorialBanner() {
    showTutorialBanner = false;
    notifyListeners();
  }

  void setWordLength(int length) {
    wordLength = length;
    greenLetters = {};
    yellowLetters = {};
    selectedPosition = null;
    results = [];
    hasQueried = false;
    // blackLetters and activeInput intentionally persist across a length change.
    notifyListeners();
  }

  void setActiveInput(InputMode mode) {
    activeInput = activeInput == mode ? InputMode.none : mode;
    selectedPosition = null;
    notifyListeners();
  }

  void selectPosition(int pos) {
    selectedPosition = pos;
    notifyListeners();
  }

  void onLetterPressed(String letter) {
    switch (activeInput) {
      case InputMode.green:
        final pos = selectedPosition;
        if (pos == null) return;
        greenLetters = {...greenLetters, pos: letter};
        yellowLetters = {...yellowLetters}..remove(pos);
        selectedPosition = pos < wordLength ? pos + 1 : null;
        notifyListeners();
      case InputMode.yellow:
        final pos = selectedPosition;
        if (pos == null) return;
        yellowLetters = {...yellowLetters, pos: letter};
        greenLetters = {...greenLetters}..remove(pos);
        selectedPosition = pos < wordLength ? pos + 1 : null;
        notifyListeners();
      case InputMode.black:
        blackLetters = {...blackLetters, letter};
        notifyListeners();
      case InputMode.none:
        break;
    }
  }

  void clearPosition(int pos) {
    greenLetters = {...greenLetters}..remove(pos);
    yellowLetters = {...yellowLetters}..remove(pos);
    notifyListeners();
  }

  void removeBlackLetter(String letter) {
    blackLetters = {...blackLetters}..remove(letter);
    notifyListeners();
  }

  void clearAll() {
    final keepLength = wordLength;
    greenLetters = {};
    yellowLetters = {};
    blackLetters = {};
    activeInput = InputMode.none;
    selectedPosition = null;
    results = [];
    isLoading = false;
    hasQueried = false;
    showTutorialBanner = false;
    wordLength = keepLength;
    notifyListeners();
  }

  Future<void> getGuesses() async {
    isLoading = true;
    showTutorialBanner = false;
    notifyListeners();

    final newResults = await _repository.getGuesses(
      wordLength: wordLength,
      greenLetters: greenLetters,
      yellowLetters: yellowLetters,
      blackLetters: blackLetters,
    );

    results = newResults;
    isLoading = false;
    hasQueried = true;
    notifyListeners();
  }
}
