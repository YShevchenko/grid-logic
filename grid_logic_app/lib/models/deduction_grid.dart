// Deduction Grid - Player's marking of known/impossible relationships

enum CellState {
  unknown, // Default - no information
  yes, // Confirmed relationship
  no, // Impossible relationship
}

class DeductionGrid {
  // Grid structure: Map of (attribute1, value1) -> (attribute2, value2) -> CellState
  final Map<String, Map<String, CellState>> _grid = {};

  DeductionGrid() {
    _initializeGrid();
  }

  void _initializeGrid() {
    // Initialize all cells to unknown
    // We need to track relationships between all attribute pairs
    _grid.clear();
  }

  CellState getState(String key1, String key2) {
    return _grid[key1]?[key2] ?? CellState.unknown;
  }

  void setState(String key1, String key2, CellState state) {
    _grid.putIfAbsent(key1, () => {});
    _grid[key1]![key2] = state;

    // Symmetric update
    _grid.putIfAbsent(key2, () => {});
    _grid[key2]![key1] = state;
  }

  void toggleState(String key1, String key2) {
    final current = getState(key1, key2);
    final next = switch (current) {
      CellState.unknown => CellState.yes,
      CellState.yes => CellState.no,
      CellState.no => CellState.unknown,
    };
    setState(key1, key2, next);
  }

  void reset() {
    _grid.clear();
    _initializeGrid();
  }

  // Export/import for save/load
  Map<String, dynamic> toJson() {
    return {
      'grid': _grid.map((k, v) => MapEntry(
            k,
            v.map((k2, v2) => MapEntry(k2, v2.index)),
          )),
    };
  }

  static DeductionGrid fromJson(Map<String, dynamic> json) {
    final grid = DeductionGrid();
    final gridData = json['grid'] as Map<String, dynamic>;
    gridData.forEach((k, v) {
      final innerMap = v as Map<String, dynamic>;
      innerMap.forEach((k2, v2) {
        grid.setState(k, k2, CellState.values[v2 as int]);
      });
    });
    return grid;
  }
}
