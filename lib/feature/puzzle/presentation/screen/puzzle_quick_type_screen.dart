import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PuzzleQuickTypeScreen extends StatefulWidget {
  const PuzzleQuickTypeScreen({super.key});

  @override
  State<PuzzleQuickTypeScreen> createState() => _PuzzleQuickTypeScreenState();
}

class _PuzzleQuickTypeScreenState extends State<PuzzleQuickTypeScreen> {
  String selectedPuzzleCount = "";
  List<String> selectedLevels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG20,
      appBar: AppBar(
        backgroundColor: ChessColors.greyG20,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: GestureDetector(
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
              height: 24,
              width: 24,
            ),
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tezkor boshqotirma",
              style: context.textTheme.largeTitle3Bold.copyWith(
                color: ChessColors.greyG900,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 16),
              child: Text(
                "Vaqt davomiyligi",
                style: context.textTheme.calloutMedium.copyWith(
                  color: ChessColors.greyG200,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _CardOption(
                    optionName: "3 minut",
                    isSelected: selectedPuzzleCount == "3",
                    onTap: () => _selectPuzzleCount("3"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CardOption(
                    optionName: "5 minut ",
                    isSelected: selectedPuzzleCount == "5",
                    onTap: () => _selectPuzzleCount("5"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 16),
              child: Text(
                "Darajasi (birnechta darajani belgilashingiz mumkin)",
                style: context.textTheme.calloutMedium.copyWith(
                  color: ChessColors.greyG200,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _CardOption(
                    optionName: "Oson",
                    isSelected: selectedLevels.contains("Oson"),
                    onTap: () => _toggleLevel("Oson"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CardOption(
                    optionName: "O’rtacha",
                    isSelected: selectedLevels.contains("O’rtacha"),
                    onTap: () => _toggleLevel("O’rtacha"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CardOption(
                    optionName: "Qiyin",
                    isSelected: selectedLevels.contains("Qiyin"),
                    onTap: () => _toggleLevel("Qiyin"),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ChessButton.primary(
              onPressed: _canStart()
                  ? () {
                      final puzzleTypes = _getPuzzleTypes(selectedLevels);
                      final limit = _getLimit(selectedPuzzleCount);
                      context.replaceRoute(
                        PuzzleQuickDetailsRoute(
                          selectedCount: selectedPuzzleCount,
                          puzzleType: puzzleTypes,
                          limit: limit,
                        ),
                      );
                    }
                  : null,
              label: 'Boshlash',
            ),
          ],
        ),
      ),
    );
  }

  void _selectPuzzleCount(String count) {
    setState(() {
      selectedPuzzleCount = count;
    });
  }

  void _toggleLevel(String level) {
    setState(() {
      if (selectedLevels.contains(level)) {
        selectedLevels.remove(level);
      } else {
        selectedLevels.add(level);
      }
    });
  }

  bool _canStart() {
    return selectedPuzzleCount.isNotEmpty && selectedLevels.isNotEmpty;
  }

  List<String> _getPuzzleTypes(List<String> levels) {
    return levels.map((level) {
      switch (level) {
        case "Oson":
          return "easy";
        case "O’rtacha":
          return "medium";
        case "Qiyin":
          return "hard";
        default:
          return "";
      }
    }).toList();
  }

  int _getLimit(String count) {
    switch (count) {
      case "3":
        return 180;
      case "5":
        return 300;
      default:
        return 100;
    }
  }
}

class _CardOption extends StatelessWidget {
  final String optionName;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardOption({
    required this.optionName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusMd,
              color:
                  isSelected ? ChessColors.primaryDefault : ChessColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  optionName,
                  style: context.textTheme.subheadlineSemibold.copyWith(
                    color: isSelected ? ChessColors.white : ChessColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
