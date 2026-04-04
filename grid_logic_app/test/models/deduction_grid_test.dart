import 'package:flutter_test/flutter_test.dart';
import 'package:grid_logic_app/models/deduction_grid.dart';

void main() {
  group('DeductionGrid', () {
    late DeductionGrid grid;

    setUp(() {
      grid = DeductionGrid();
    });

    test('initializes with unknown state', () {
      final state = grid.getState('key1', 'key2');
      expect(state, CellState.unknown);
    });

    test('setState updates cell state', () {
      grid.setState('key1', 'key2', CellState.yes);
      expect(grid.getState('key1', 'key2'), CellState.yes);
    });

    test('setState is symmetric', () {
      grid.setState('key1', 'key2', CellState.yes);
      expect(grid.getState('key2', 'key1'), CellState.yes);
    });

    test('toggleState cycles through states', () {
      expect(grid.getState('key1', 'key2'), CellState.unknown);

      grid.toggleState('key1', 'key2');
      expect(grid.getState('key1', 'key2'), CellState.yes);

      grid.toggleState('key1', 'key2');
      expect(grid.getState('key1', 'key2'), CellState.no);

      grid.toggleState('key1', 'key2');
      expect(grid.getState('key1', 'key2'), CellState.unknown);
    });

    test('toggleState maintains symmetry', () {
      grid.toggleState('key1', 'key2');
      expect(grid.getState('key2', 'key1'), CellState.yes);
    });

    test('reset clears all states', () {
      grid.setState('key1', 'key2', CellState.yes);
      grid.setState('key3', 'key4', CellState.no);

      grid.reset();

      expect(grid.getState('key1', 'key2'), CellState.unknown);
      expect(grid.getState('key3', 'key4'), CellState.unknown);
    });

    test('toJson exports grid state', () {
      grid.setState('key1', 'key2', CellState.yes);
      grid.setState('key3', 'key4', CellState.no);

      final json = grid.toJson();
      expect(json, isNotNull);
      expect(json['grid'], isNotNull);
    });

    test('fromJson imports grid state', () {
      grid.setState('key1', 'key2', CellState.yes);
      grid.setState('key3', 'key4', CellState.no);

      final json = grid.toJson();
      final newGrid = DeductionGrid.fromJson(json);

      expect(newGrid.getState('key1', 'key2'), CellState.yes);
      expect(newGrid.getState('key3', 'key4'), CellState.no);
    });

    test('handles multiple keys correctly', () {
      grid.setState('a', 'b', CellState.yes);
      grid.setState('c', 'd', CellState.no);
      grid.setState('e', 'f', CellState.unknown);

      expect(grid.getState('a', 'b'), CellState.yes);
      expect(grid.getState('c', 'd'), CellState.no);
      expect(grid.getState('e', 'f'), CellState.unknown);
    });
  });

  group('CellState', () {
    test('has three states', () {
      expect(CellState.values.length, 3);
      expect(CellState.values, contains(CellState.unknown));
      expect(CellState.values, contains(CellState.yes));
      expect(CellState.values, contains(CellState.no));
    });

    test('has correct indices', () {
      expect(CellState.unknown.index, 0);
      expect(CellState.yes.index, 1);
      expect(CellState.no.index, 2);
    });
  });
}
