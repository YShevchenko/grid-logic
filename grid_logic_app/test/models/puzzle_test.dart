import 'package:flutter_test/flutter_test.dart';
import 'package:grid_logic_app/models/puzzle.dart';

void main() {
  group('Attribute', () {
    test('has five attributes', () {
      expect(Attribute.values.length, 5);
      expect(Attribute.values, contains(Attribute.color));
      expect(Attribute.values, contains(Attribute.nationality));
      expect(Attribute.values, contains(Attribute.pet));
      expect(Attribute.values, contains(Attribute.drink));
      expect(Attribute.values, contains(Attribute.hobby));
    });
  });

  group('AttributeValue', () {
    test('creates attribute value correctly', () {
      final av = AttributeValue(Attribute.color, 'Red');
      expect(av.attribute, Attribute.color);
      expect(av.value, 'Red');
    });

    test('equality works correctly', () {
      final av1 = AttributeValue(Attribute.color, 'Red');
      final av2 = AttributeValue(Attribute.color, 'Red');
      final av3 = AttributeValue(Attribute.color, 'Blue');

      expect(av1, av2);
      expect(av1, isNot(av3));
    });

    test('toString returns correct format', () {
      final av = AttributeValue(Attribute.color, 'Red');
      expect(av.toString(), contains('color'));
      expect(av.toString(), contains('Red'));
    });
  });

  group('House', () {
    test('creates house with position and attributes', () {
      final house = House(
        position: 0,
        attributes: {
          Attribute.color: 'Red',
          Attribute.nationality: 'British',
        },
      );

      expect(house.position, 0);
      expect(house.getAttribute(Attribute.color), 'Red');
      expect(house.getAttribute(Attribute.nationality), 'British');
    });

    test('getAttribute returns null for missing attribute', () {
      final house = House(position: 0, attributes: {});
      expect(house.getAttribute(Attribute.color), isNull);
    });

    test('hasAttribute checks correctly', () {
      final house = House(
        position: 0,
        attributes: {Attribute.color: 'Red'},
      );

      expect(house.hasAttribute(Attribute.color, 'Red'), true);
      expect(house.hasAttribute(Attribute.color, 'Blue'), false);
      expect(house.hasAttribute(Attribute.nationality, 'British'), false);
    });
  });

  group('Clue', () {
    test('creates clue with text, type, and data', () {
      final clue = Clue(
        text: 'The British person lives in the red house',
        type: ClueType.same,
        data: {'attr1': 'nationality', 'value1': 'British'},
      );

      expect(clue.text, 'The British person lives in the red house');
      expect(clue.type, ClueType.same);
      expect(clue.data, isNotEmpty);
    });

    test('toString returns clue text', () {
      final clue = Clue(
        text: 'Test clue',
        type: ClueType.same,
        data: {},
      );

      expect(clue.toString(), 'Test clue');
    });
  });

  group('ClueType', () {
    test('has four types', () {
      expect(ClueType.values.length, 4);
      expect(ClueType.values, contains(ClueType.same));
      expect(ClueType.values, contains(ClueType.adjacent));
      expect(ClueType.values, contains(ClueType.position));
      expect(ClueType.values, contains(ClueType.order));
    });
  });

  group('Puzzle', () {
    test('creates puzzle with houses and clues', () {
      final houses = [
        House(position: 0, attributes: {Attribute.color: 'Red'}),
        House(position: 1, attributes: {Attribute.color: 'Blue'}),
      ];

      final clues = [
        Clue(text: 'Test', type: ClueType.same, data: {}),
      ];

      final puzzle = Puzzle(
        houses: houses,
        clues: clues,
        difficulty: 5,
      );

      expect(puzzle.houses.length, 2);
      expect(puzzle.clues.length, 1);
      expect(puzzle.difficulty, 5);
    });

    test('possibleValues contains all attributes', () {
      expect(Puzzle.possibleValues.keys, containsAll(Attribute.values));
      expect(Puzzle.possibleValues[Attribute.color]?.length, 5);
      expect(Puzzle.possibleValues[Attribute.nationality]?.length, 5);
      expect(Puzzle.possibleValues[Attribute.pet]?.length, 5);
      expect(Puzzle.possibleValues[Attribute.drink]?.length, 5);
      expect(Puzzle.possibleValues[Attribute.hobby]?.length, 5);
    });

    test('findHouse returns correct house', () {
      final houses = [
        House(position: 0, attributes: {Attribute.color: 'Red'}),
        House(position: 1, attributes: {Attribute.color: 'Blue'}),
      ];

      final puzzle = Puzzle(houses: houses, clues: [], difficulty: 1);

      final redHouse = puzzle.findHouse(Attribute.color, 'Red');
      expect(redHouse?.position, 0);

      final blueHouse = puzzle.findHouse(Attribute.color, 'Blue');
      expect(blueHouse?.position, 1);
    });

    test('findHouse returns null when not found', () {
      final houses = [
        House(position: 0, attributes: {Attribute.color: 'Red'}),
      ];

      final puzzle = Puzzle(houses: houses, clues: [], difficulty: 1);

      final greenHouse = puzzle.findHouse(Attribute.color, 'Green');
      expect(greenHouse, isNull);
    });
  });
}
