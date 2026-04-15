// ignore_for_file: file_names

import 'package:codey/models/entities/exercise_MTC.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseMTCWidget extends StatefulWidget {
  final ExerciseMTC exercise;
  final ValueChanged<bool> onAnswerSelected;
  final Widget statementArea;
  final ValueListenable<bool> changesEnabled;

  const ExerciseMTCWidget({
    super.key,
    required this.exercise,
    required this.onAnswerSelected,
    required this.statementArea,
    required this.changesEnabled,
  });

  @override
  State<ExerciseMTCWidget> createState() => _ExerciseMTCWidgetState();
}

class _ExerciseMTCWidgetState extends State<ExerciseMTCWidget> {
  int? _selectedLeftIndex;
  int? _selectedRightShuffledIndex;
  final Set<int> _matchedLeftIndices = {};
  final Set<int> _matchedRightIndices = {};
  int? _flashingRightIndex;  // shuffled index — red (incorrect)
  int? _flashingLeftIndex;   // left index — red (incorrect)
  int? _flashingCorrectLeftIndex; // left index — green (correct)
  int? _flashingCorrectShuffledIndex; // shuffled right index — green (correct)

  late List<int>
      _shuffledRightOrder; // shuffledRightOrder[i] = original right index

  @override
  void initState() {
    super.initState();
    _shuffledRightOrder =
        List.generate(widget.exercise.rightItems.length, (i) => i);
    _shuffledRightOrder.shuffle();
  }

  void _onLeftTap(int leftIndex) {
    if (!widget.changesEnabled.value) return;
    if (_matchedLeftIndices.contains(leftIndex)) return;
    if (_selectedRightShuffledIndex != null) {
      _attemptMatch(leftIndex, _selectedRightShuffledIndex!);
    } else {
      setState(() {
        _selectedLeftIndex = (_selectedLeftIndex == leftIndex) ? null : leftIndex;
      });
    }
  }

  void _onRightTap(int shuffledIndex) {
    if (!widget.changesEnabled.value) return;
    final originalRightIndex = _shuffledRightOrder[shuffledIndex];
    if (_matchedRightIndices.contains(originalRightIndex)) return;
    if (_selectedLeftIndex != null) {
      _attemptMatch(_selectedLeftIndex!, shuffledIndex);
    } else {
      setState(() {
        _selectedRightShuffledIndex =
            (_selectedRightShuffledIndex == shuffledIndex) ? null : shuffledIndex;
      });
    }
  }

  void _attemptMatch(int leftIndex, int shuffledIndex) async {
    final originalRightIndex = _shuffledRightOrder[shuffledIndex];
    if (originalRightIndex == leftIndex) {
      setState(() {
        _selectedLeftIndex = null;
        _selectedRightShuffledIndex = null;
        _flashingCorrectLeftIndex = leftIndex;
        _flashingCorrectShuffledIndex = shuffledIndex;
        _matchedLeftIndices.add(leftIndex);
        _matchedRightIndices.add(originalRightIndex);
      });
      final isLast =
          _matchedLeftIndices.length == widget.exercise.leftItems.length;
      if (isLast) widget.onAnswerSelected(true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _flashingCorrectLeftIndex = null;
        _flashingCorrectShuffledIndex = null;
      });
    } else {
      setState(() {
        _flashingRightIndex = shuffledIndex;
        _flashingLeftIndex = leftIndex;
        _selectedLeftIndex = null;
        _selectedRightShuffledIndex = null;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _flashingRightIndex = null;
          _flashingLeftIndex = null;
        });
      }
    }
  }

  static const double _maxColumnWidth = 160;
  static const double _minColumnWidth = 120;
  static const double _maxColumnGap = 120;
  static const double _minColumnGap = 20;
  static const double _itemVerticalMargin = 16;

  Widget _buildColumn({
    required BuildContext context,
    required double columnWidth,
    required int itemCount,
    required String Function(int i) text,
    required bool Function(int i) matched,
    required bool Function(int i) highlighted,
    required bool Function(int i) flashingRed,
    required VoidCallback Function(int i) onTap,
  }) {
    return SizedBox(
      width: columnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
            itemCount,
            (i) => _buildCard(
                  context: context,
                  text: text(i),
                  matched: matched(i),
                  highlighted: highlighted(i),
                  flashingRed: flashingRed(i),
                  onTap: onTap(i),
                )),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String text,
    required bool matched,
    required bool highlighted, // selected (left) or flashingGreen (right)
    required bool flashingRed, // only right column uses this
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color borderColor;
    final Color bgColor;

    if (flashingRed) {
      borderColor = colorScheme.error;
      bgColor = colorScheme.errorContainer;
    } else if (highlighted) {
      borderColor = colorScheme.primary;
      bgColor = colorScheme.primaryContainer;
    } else if (matched) {
      borderColor = colorScheme.outline.withOpacity(0.3);
      bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.4);
    } else {
      borderColor = colorScheme.outline.withOpacity(0.6);
      bgColor = colorScheme.surfaceContainerHighest;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: _itemVerticalMargin),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
          color: bgColor,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: matched ? colorScheme.onSurface.withOpacity(0.4) : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: widget.statementArea,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth;
            double gap = (available * 0.15).clamp(_minColumnGap, _maxColumnGap);
            double columnWidth =
                ((available - gap) / 2).clamp(_minColumnWidth, _maxColumnWidth);
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColumn(
                    context: context,
                    columnWidth: columnWidth,
                    itemCount: widget.exercise.leftItems.length,
                    text: (i) => widget.exercise.leftItems[i],
                    matched: (i) => _matchedLeftIndices.contains(i),
                    highlighted: (i) =>
                        _selectedLeftIndex == i ||
                        _flashingCorrectLeftIndex == i,
                    flashingRed: (i) => _flashingLeftIndex == i,
                    onTap: (i) => () => _onLeftTap(i),
                  ),
                  SizedBox(width: gap),
                  _buildColumn(
                    context: context,
                    columnWidth: columnWidth,
                    itemCount: _shuffledRightOrder.length,
                    text: (i) =>
                        widget.exercise.rightItems[_shuffledRightOrder[i]],
                    matched: (i) =>
                        _matchedRightIndices.contains(_shuffledRightOrder[i]),
                    highlighted: (i) =>
                        _flashingCorrectShuffledIndex == i ||
                        _selectedRightShuffledIndex == i,
                    flashingRed: (i) => _flashingRightIndex == i,
                    onTap: (i) => () => _onRightTap(i),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
