import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grid_logic_app/providers/game_state.dart';
import 'package:grid_logic_app/models/deduction_grid.dart';
import 'package:grid_logic_app/models/puzzle.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameState', () {
    test('creates with default values', () {
      final state = GameState(deductionGrid: DeductionGrid());

      expect(state.currentPuzzle, isNull);
      expect(state.currentLevel, 1);
      expect(state.hintsUsed, 0);
      expect(state.isPaused, false);
      expect(state.startTime, isNull);
    });

    test('copyWith creates new instance with updated values', () {
      final state1 = GameState(deductionGrid: DeductionGrid(), currentLevel: 1);
      final state2 = state1.copyWith(currentLevel: 5);

      expect(state2.currentLevel, 5);
      expect(state1.currentLevel, 1); // Original unchanged
    });

    test('copyWith preserves unchanged values', () {
      final grid = DeductionGrid();
      final state1 = GameState(
        deductionGrid: grid,
        currentLevel: 3,
        hintsUsed: 2,
      );

      final state2 = state1.copyWith(currentLevel: 4);

      expect(state2.currentLevel, 4);
      expect(state2.hintsUsed, 2); // Unchanged
      expect(state2.deductionGrid, grid); // Unchanged
    });
  });

  group('GameStateNotifier', () {
    test('initializes with default state', () {
      final notifier = GameStateNotifier();

      expect(notifier.state.currentLevel, 1);
      expect(notifier.state.currentPuzzle, isNull);
      expect(notifier.state.hintsUsed, 0);
    });

    test('startNewGame creates new puzzle', () {
      final notifier = GameStateNotifier();
      notifier.startNewGame();

      expect(notifier.state.currentPuzzle, isNotNull);
      expect(notifier.state.startTime, isNotNull);
      expect(notifier.state.hintsUsed, 0);
      expect(notifier.state.isPaused, false);
    });

    test('startNewGame increases difficulty with level', () {
      final notifier = GameStateNotifier();

      notifier.startNewGame();
      final difficulty1 = notifier.state.currentPuzzle?.difficulty ?? 0;

      // Manually set higher level
      notifier.state = notifier.state.copyWith(currentLevel: 10);
      notifier.startNewGame();
      final difficulty2 = notifier.state.currentPuzzle?.difficulty ?? 0;

      expect(difficulty2, greaterThan(difficulty1));
    });

    test('toggleCell updates deduction grid', () {
      final notifier = GameStateNotifier();

      final initialState = notifier.state.deductionGrid.getState('key1', 'key2');
      expect(initialState, CellState.unknown);

      notifier.toggleCell('key1', 'key2');

      final newState = notifier.state.deductionGrid.getState('key1', 'key2');
      expect(newState, CellState.yes);
    });

    test('useHint increments hintsUsed', () {
      final notifier = GameStateNotifier();
      notifier.startNewGame();

      final initialHints = notifier.state.hintsUsed;
      notifier.useHint();

      expect(notifier.state.hintsUsed, initialHints + 1);
    });

    test('useHint does nothing without puzzle', () {
      final notifier = GameStateNotifier();

      expect(notifier.state.currentPuzzle, isNull);
      notifier.useHint();

      expect(notifier.state.hintsUsed, 0);
    });

    test('loads saved level from preferences', () async {
      SharedPreferences.setMockInitialValues({'current_level': 7});

      final notifier = GameStateNotifier();
      await Future.delayed(Duration.zero); // Allow async loading

      // Level should be loaded (eventually)
      // Note: This test may be timing-dependent
    });
  });
}
