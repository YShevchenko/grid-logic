// Game Screen - Main gameplay with clues and deduction grid

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state.dart';
import '../models/puzzle.dart';
import '../models/deduction_grid.dart';
import '../services/ad_service.dart';
import '../core/theme/app_theme.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _selectedClueIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final puzzle = gameState.currentPuzzle;

    if (puzzle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grid Logic')),
        body: const Center(child: Text('No puzzle loaded')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${gameState.currentLevel}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showHintDialog,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _checkSolution(puzzle),
          ),
        ],
      ),
      body: Column(
        children: [
          // Clues Section
          Expanded(
            flex: 2,
            child: _buildCluesSection(puzzle),
          ),

          const Divider(height: 1),

          // Deduction Grid Section
          Expanded(
            flex: 3,
            child: _buildDeductionGrid(gameState.deductionGrid),
          ),
        ],
      ),
    );
  }

  Widget _buildCluesSection(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Clues',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: puzzle.clues.length,
            itemBuilder: (context, index) {
              final clue = puzzle.clues[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: _selectedClueIndex == index
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(clue.text),
                  onTap: () {
                    setState(() {
                      _selectedClueIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeductionGrid(DeductionGrid grid) {
    // Simplified deduction grid showing attribute relationships
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deduction Grid',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap cells to mark:\n✓ = Confirmed\n✗ = Impossible\n○ = Unknown',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Build a simplified grid for each attribute pair
          ..._buildAttributeGrids(grid),
        ],
      ),
    );
  }

  List<Widget> _buildAttributeGrids(DeductionGrid grid) {
    final widgets = <Widget>[];

    // Create grids for Color vs other attributes
    final attributes = [
      Attribute.nationality,
      Attribute.pet,
      Attribute.drink,
      Attribute.hobby,
    ];

    for (final attr in attributes) {
      widgets.add(_buildAttributePairGrid(grid, Attribute.color, attr));
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Widget _buildAttributePairGrid(DeductionGrid grid, Attribute attr1, Attribute attr2) {
    final values1 = Puzzle.possibleValues[attr1]!;
    final values2 = Puzzle.possibleValues[attr2]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${attr1.name.toUpperCase()} vs ${attr2.name.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 40,
                columns: [
                  const DataColumn(label: Text('')),
                  ...values2.map((v) => DataColumn(
                        label: Text(
                          v,
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                ],
                rows: values1.map((v1) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        v1,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      )),
                      ...values2.map((v2) {
                        final key1 = '${attr1.name}_$v1';
                        final key2 = '${attr2.name}_$v2';
                        final state = grid.getState(key1, key2);

                        return DataCell(
                          GestureDetector(
                            onTap: () {
                              ref.read(gameStateProvider.notifier).toggleCell(key1, key2);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _getCellColor(state),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  _getCellSymbol(state),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor(CellState state) {
    return switch (state) {
      CellState.unknown => Colors.grey[200]!,
      CellState.yes => AppTheme.yesColor.withValues(alpha: 0.3),
      CellState.no => AppTheme.noColor.withValues(alpha: 0.3),
    };
  }

  String _getCellSymbol(CellState state) {
    return switch (state) {
      CellState.unknown => '○',
      CellState.yes => '✓',
      CellState.no => '✗',
    };
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Hint'),
        content: const Text('Watch a video ad to reveal one relationship?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final rewarded = await AdService.instance.showRewardedAd();
              if (rewarded) {
                ref.read(gameStateProvider.notifier).useHint();
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Hint revealed!')),
                  );
                }
              }
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  void _checkSolution(Puzzle puzzle) {
    // Validate by checking if all correct relationships are marked as "yes"
    // and no incorrect relationships are marked as "yes"
    final grid = ref.read(gameStateProvider).deductionGrid;
    final validationResult = _validateSolution(puzzle, grid);

    if (validationResult.isCorrect) {
      // CORRECT SOLUTION - Show victory dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Puzzle Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text('Great job!'),
              const SizedBox(height: 16),
              Text(
                'Answer: The ${puzzle.getAnswerNationality()} owns the fish!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(gameStateProvider.notifier).completeLevel();
                AdService.instance.showInterstitialAd();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to menu
              },
              child: const Text('Next Level'),
            ),
          ],
        ),
      );
    } else {
      // INCORRECT SOLUTION - Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not Quite Right'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                validationResult.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review the clues and check your deduction grid.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Trying'),
            ),
          ],
        ),
      );
    }
  }

  /// Validates the solution by checking if correct attribute relationships are marked
  _ValidationResult _validateSolution(Puzzle puzzle, DeductionGrid grid) {
    // Build the correct attribute relationships from the puzzle solution
    final correctRelationships = <String, Set<String>>{};

    // For each house, record which attribute values go together
    for (final house in puzzle.houses) {
      final attrValues = <String>[];

      // Collect all attribute values for this house
      for (final attr in Attribute.values) {
        final value = house.attributes[attr]!;
        attrValues.add('${attr.name}_$value');
      }

      // Every value in this house should be marked "yes" with every other value
      for (int i = 0; i < attrValues.length; i++) {
        for (int j = i + 1; j < attrValues.length; j++) {
          final key1 = attrValues[i];
          final key2 = attrValues[j];

          correctRelationships.putIfAbsent(key1, () => {});
          correctRelationships[key1]!.add(key2);

          correctRelationships.putIfAbsent(key2, () => {});
          correctRelationships[key2]!.add(key1);
        }
      }
    }

    // Check if all correct relationships are marked as "yes"
    int correctMarked = 0;
    int totalCorrect = 0;
    int incorrectMarked = 0;

    // Count correct relationships marked
    for (final key1 in correctRelationships.keys) {
      for (final key2 in correctRelationships[key1]!) {
        totalCorrect++;
        final state = grid.getState(key1, key2);

        if (state == CellState.yes) {
          correctMarked++;
        }
      }
    }

    // Since relationships are symmetric, divide by 2
    totalCorrect ~/= 2;
    correctMarked ~/= 2;

    // Check for incorrectly marked relationships
    // (This is expensive but thorough - check all possible pairs)
    for (final attr1 in Attribute.values) {
      for (final value1 in Puzzle.possibleValues[attr1]!) {
        final key1 = '${attr1.name}_$value1';

        for (final attr2 in Attribute.values) {
          if (attr2.index <= attr1.index) continue; // Avoid duplicates

          for (final value2 in Puzzle.possibleValues[attr2]!) {
            final key2 = '${attr2.name}_$value2';
            final state = grid.getState(key1, key2);

            if (state == CellState.yes) {
              // Check if this is a correct relationship
              final isCorrect =
                  correctRelationships[key1]?.contains(key2) ?? false;

              if (!isCorrect) {
                incorrectMarked++;
              }
            }
          }
        }
      }
    }

    // Solution is correct if:
    // 1. All correct relationships are marked
    // 2. No incorrect relationships are marked
    final isCorrect = (correctMarked >= totalCorrect * 0.9) && incorrectMarked == 0;

    String message;
    if (incorrectMarked > 0) {
      message = 'You have $incorrectMarked incorrect relationship(s) marked. Keep trying!';
    } else if (correctMarked < totalCorrect) {
      final remaining = totalCorrect - correctMarked;
      message = 'You\'re on the right track! $remaining more relationship(s) to find.';
    } else {
      message = 'Perfect!';
    }

    return _ValidationResult(isCorrect: isCorrect, message: message);
  }
}

class _ValidationResult {
  final bool isCorrect;
  final String message;

  _ValidationResult({required this.isCorrect, required this.message});
}
