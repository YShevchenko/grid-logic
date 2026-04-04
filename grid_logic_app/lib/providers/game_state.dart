// Game State Management - Riverpod providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle.dart';
import '../models/deduction_grid.dart';
import '../game/puzzle_generator.dart';

// Game State
class GameState {
  final Puzzle? currentPuzzle;
  final DeductionGrid deductionGrid;
  final int currentLevel;
  final int hintsUsed;
  final bool isPaused;
  final DateTime? startTime;

  GameState({
    this.currentPuzzle,
    required this.deductionGrid,
    this.currentLevel = 1,
    this.hintsUsed = 0,
    this.isPaused = false,
    this.startTime,
  });

  GameState copyWith({
    Puzzle? currentPuzzle,
    DeductionGrid? deductionGrid,
    int? currentLevel,
    int? hintsUsed,
    bool? isPaused,
    DateTime? startTime,
  }) {
    return GameState(
      currentPuzzle: currentPuzzle ?? this.currentPuzzle,
      deductionGrid: deductionGrid ?? this.deductionGrid,
      currentLevel: currentLevel ?? this.currentLevel,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
    );
  }
}

// Game State Notifier
class GameStateNotifier extends StateNotifier<GameState> {
  final PuzzleGenerator _generator = PuzzleGenerator();

  GameStateNotifier() : super(GameState(deductionGrid: DeductionGrid())) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt('current_level') ?? 1;
    state = state.copyWith(currentLevel: level);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_level', state.currentLevel);
  }

  void startNewGame() {
    final difficulty = (state.currentLevel / 2).ceil().clamp(1, 10);
    final puzzle = _generator.generate(difficulty: difficulty);

    state = GameState(
      currentPuzzle: puzzle,
      deductionGrid: DeductionGrid(),
      currentLevel: state.currentLevel,
      hintsUsed: 0,
      isPaused: false,
      startTime: DateTime.now(),
    );
  }

  void toggleCell(String key1, String key2) {
    state.deductionGrid.toggleState(key1, key2);
    state = state.copyWith(); // Trigger rebuild
  }

  void useHint() {
    if (state.currentPuzzle == null) return;

    // Find a random cell that should be marked as "yes"
    final puzzle = state.currentPuzzle!;

    // Simple hint: reveal one correct relationship
    final houseIndex = state.hintsUsed % 5;
    final house = puzzle.houses[houseIndex];

    // Mark one attribute relationship as correct
    final attrs = Attribute.values.toList();
    if (houseIndex < attrs.length - 1) {
      final attr1 = attrs[houseIndex];
      final attr2 = attrs[houseIndex + 1];

      final value1 = house.attributes[attr1]!;
      final value2 = house.attributes[attr2]!;

      state.deductionGrid.setState(
        '${attr1.name}_$value1',
        '${attr2.name}_$value2',
        CellState.yes,
      );
    }

    state = state.copyWith(hintsUsed: state.hintsUsed + 1);
  }

  void pauseGame() {
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    state = state.copyWith(isPaused: false);
  }

  void completeLevel() {
    state = state.copyWith(currentLevel: state.currentLevel + 1);
    _saveProgress();
  }

  void resetGame() {
    state = GameState(
      deductionGrid: DeductionGrid(),
      currentLevel: 1,
    );
    _saveProgress();
  }
}

// Providers
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// High Score Provider
class HighScoreNotifier extends StateNotifier<int> {
  HighScoreNotifier() : super(0) {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('high_score') ?? 0;
  }

  Future<void> updateHighScore(int score) async {
    if (score > state) {
      state = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score', score);
    }
  }
}

final highScoreProvider = StateNotifierProvider<HighScoreNotifier, int>((ref) {
  return HighScoreNotifier();
});

// Theme Provider
enum AppThemeMode { light, dark }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_theme') ?? false;
    state = isDark ? AppThemeMode.dark : AppThemeMode.light;
  }

  Future<void> toggleTheme() async {
    state = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', state == AppThemeMode.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
