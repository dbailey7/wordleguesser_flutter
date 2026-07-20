import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../wordle_notifier.dart';

class WordleScreen extends StatelessWidget {
  final VoidCallback onShowHelp;
  final VoidCallback onResetDemo;

  const WordleScreen({
    super.key,
    required this.onShowHelp,
    required this.onResetDemo,
  });

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: onboardingCardBackground,
        title: const Text(
          'Reset to first-run experience?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'The onboarding and tutorial sample will replay from the beginning.',
          style: TextStyle(color: wordleGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: wordleGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: wordleGreen)),
          ),
        ],
      ),
    );
    if (confirmed == true) onResetDemo();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<WordleNotifier>();

    return Scaffold(
      backgroundColor: wordleDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                onShowHelp: onShowHelp,
                onLongPress: () => _showResetDialog(context),
              ),
              if (notifier.showTutorialBanner) ...[
                const SizedBox(height: 6),
                _TutorialBanner(onDismiss: notifier.dismissTutorialBanner),
              ],
              const SizedBox(height: 6),
              _WordLengthSelector(
                wordLength: notifier.wordLength,
                onSelected: notifier.setWordLength,
              ),
              const SizedBox(height: 6),
              _InputModeSelector(
                activeMode: notifier.activeInput,
                onSelected: notifier.setActiveInput,
              ),
              const SizedBox(height: 6),
              _PositionGrid(
                wordLength: notifier.wordLength,
                greenLetters: notifier.greenLetters,
                yellowLetters: notifier.yellowLetters,
                selectedPosition: notifier.selectedPosition,
                onSelect: notifier.selectPosition,
                onClear: notifier.clearPosition,
              ),
              if (notifier.blackLetters.isNotEmpty) ...[
                const SizedBox(height: 6),
                _BlackLettersSummary(
                  letters: notifier.blackLetters,
                  onRemove: notifier.removeBlackLetter,
                ),
              ],
              const SizedBox(height: 6),
              _QwertyKeyboard(
                activeMode: notifier.activeInput,
                greenLetters: notifier.greenLetters,
                yellowLetters: notifier.yellowLetters,
                blackLetters: notifier.blackLetters,
                onLetterPressed: notifier.onLetterPressed,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 13,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wordleGray,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: notifier.clearAll,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 17,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wordleGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: notifier.getGuesses,
                      child: const Text(
                        'Get Guesses',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (notifier.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: wordleGreen),
                  ),
                )
              else if (notifier.hasQueried)
                _ResultsList(results: notifier.results),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onShowHelp;
  final VoidCallback onLongPress;

  const _Header({required this.onShowHelp, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Wordle Guesser',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: onShowHelp,
              onLongPress: onLongPress,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('❓', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _TutorialBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tutorialBannerBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 28),
            child: Text(
              'Sample loaded (STARE). Tap Get Guesses to see it in action, '
              'then Clear All when ready.',
              style: TextStyle(fontSize: 12, color: wordleGreen, height: 18 / 12),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDismiss,
              child: const Text('✕', style: TextStyle(fontSize: 16, color: wordleGray)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordLengthSelector extends StatelessWidget {
  final int wordLength;
  final ValueChanged<int> onSelected;

  const _WordLengthSelector({required this.wordLength, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 76,
          child: Text(
            'Length:',
            style: TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 1,
          ),
        ),
        for (final len in [4, 5, 6, 7]) ...[
          _LengthButton(
            length: len,
            selected: len == wordLength,
            onTap: () => onSelected(len),
          ),
          if (len != 7) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _LengthButton extends StatelessWidget {
  final int length;
  final bool selected;
  final VoidCallback onTap;

  const _LengthButton({
    required this.length,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? wordleGreen : wordleGray,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$length',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _InputModeSelector extends StatelessWidget {
  final InputMode activeMode;
  final ValueChanged<InputMode> onSelected;

  const _InputModeSelector({required this.activeMode, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'Green',
            color: wordleGreen,
            active: activeMode == InputMode.green,
            onTap: () => onSelected(InputMode.green),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ModeButton(
            label: 'Yellow',
            color: wordleYellow,
            active: activeMode == InputMode.yellow,
            onTap: () => onSelected(InputMode.yellow),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ModeButton(
            label: 'Black',
            color: wordleGray,
            active: activeMode == InputMode.black,
            onTap: () => onSelected(InputMode.black),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _PositionGrid extends StatelessWidget {
  final int wordLength;
  final Map<int, String> greenLetters;
  final Map<int, Set<String>> yellowLetters;
  final int? selectedPosition;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onClear;

  const _PositionGrid({
    required this.wordLength,
    required this.greenLetters,
    required this.yellowLetters,
    required this.selectedPosition,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var pos = 1; pos <= wordLength; pos++) ...[
          if (pos != 1) const SizedBox(width: 4),
          Expanded(child: _PositionTile(
            pos: pos,
            green: greenLetters[pos],
            yellow: yellowLetters[pos] ?? const {},
            selected: pos == selectedPosition,
            onSelect: onSelect,
            onClear: onClear,
          )),
        ],
      ],
    );
  }
}

class _PositionTile extends StatelessWidget {
  final int pos;
  final String? green;
  final Set<String> yellow;
  final bool selected;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onClear;

  const _PositionTile({
    required this.pos,
    required this.green,
    required this.yellow,
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = green != null || yellow.isNotEmpty;
    final displayText = green != null
        ? green!.toUpperCase()
        : yellow.isNotEmpty
            ? (yellow.toList()..sort()).map((l) => l.toUpperCase()).join(',')
            : '$pos';
    // Shrink the font as more yellow letters share one tile so they still fit.
    final fontSize = green != null || yellow.length <= 1
        ? 20.0
        : yellow.length == 2
            ? 15.0
            : 12.0;
    final bg = green != null ? wordleGreen : (yellow.isNotEmpty ? wordleYellow : tileNeutral);

    return GestureDetector(
      // Green is a single, settled value — tap clears it. A Yellow tile can
      // hold more than one letter (each from a different guess), so tap
      // re-selects it for adding another letter instead of wiping it;
      // long-press clears it, mirroring the app's ❓ tap-vs-long-press pattern.
      onTap: () => green != null ? onClear(pos) : onSelect(pos),
      onLongPress: () => isOccupied ? onClear(pos) : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? Colors.white : wordleGray,
              width: selected ? 3 : 1,
            ),
          ),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlackLettersSummary extends StatelessWidget {
  final Set<String> letters;
  final ValueChanged<String> onRemove;

  const _BlackLettersSummary({required this.letters, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final sorted = letters.toList()..sort();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Excluded:', style: TextStyle(color: wordleGray, fontSize: 12)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final letter in sorted)
                GestureDetector(
                  onTap: () => onRemove(letter),
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: wordleDark,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: wordleGray, width: 1),
                    ),
                    child: Text(
                      letter.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

const _kbRows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];

class _QwertyKeyboard extends StatelessWidget {
  final InputMode activeMode;
  final Map<int, String> greenLetters;
  final Map<int, Set<String>> yellowLetters;
  final Set<String> blackLetters;
  final ValueChanged<String> onLetterPressed;

  const _QwertyKeyboard({
    required this.activeMode,
    required this.greenLetters,
    required this.yellowLetters,
    required this.blackLetters,
    required this.onLetterPressed,
  });

  Color _keyColor(String letter, bool enabled) {
    if (!enabled) return tileNeutral;
    if (blackLetters.contains(letter)) return wordleDark;
    if (greenLetters.values.contains(letter)) return wordleGreen;
    if (yellowLetters.values.any((set) => set.contains(letter))) return wordleYellow;
    if (activeMode == InputMode.green) return wordleGreen.withValues(alpha: 0.55);
    if (activeMode == InputMode.yellow) return wordleYellow.withValues(alpha: 0.55);
    return tileNeutral;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = activeMode != InputMode.none;
    return Column(
      children: [
        for (var i = 0; i < _kbRows.length; i++) ...[
          if (i != 0) const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final ch in _kbRows[i].split('')) ...[
                if (ch != _kbRows[i][0]) const SizedBox(width: 3),
                Expanded(
                  child: GestureDetector(
                    onTap: enabled ? () => onLetterPressed(ch) : null,
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _keyColor(ch, enabled),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ch.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    final count = results.length;
    final shown = results.take(100).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count match${count == 1 ? '' : 'es'}',
          style: const TextStyle(color: wordleGray, fontSize: 13),
        ),
        const SizedBox(height: 4),
        for (final r in shown) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    r.word as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  r.rank == null ? '—' : '${r.rank}',
                  style: const TextStyle(color: wordleGray, fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(color: tileNeutral, thickness: 0.5, height: 0.5),
        ],
      ],
    );
  }
}
