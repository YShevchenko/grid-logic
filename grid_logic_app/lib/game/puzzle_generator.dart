// Puzzle Generator - Creates valid puzzles using constraint satisfaction

import 'dart:math';
import '../models/puzzle.dart';

class PuzzleGenerator {
  final Random _random = Random();

  // Generate a valid puzzle with specified difficulty
  Puzzle generate({int difficulty = 5}) {
    // Generate a valid solution first
    final houses = _generateValidSolution();

    // Generate clues based on the solution
    final clues = _generateClues(houses, difficulty);

    return Puzzle(
      houses: houses,
      clues: clues,
      difficulty: difficulty,
    );
  }

  // Generate a valid solution using constraint satisfaction
  List<House> _generateValidSolution() {
    // Shuffle all possible values
    final colors = List<String>.from(Puzzle.possibleValues[Attribute.color]!)..shuffle(_random);
    final nationalities = List<String>.from(Puzzle.possibleValues[Attribute.nationality]!)..shuffle(_random);
    final pets = List<String>.from(Puzzle.possibleValues[Attribute.pet]!)..shuffle(_random);
    final drinks = List<String>.from(Puzzle.possibleValues[Attribute.drink]!)..shuffle(_random);
    final hobbies = List<String>.from(Puzzle.possibleValues[Attribute.hobby]!)..shuffle(_random);

    // Create 5 houses with shuffled attributes
    final houses = <House>[];
    for (int i = 0; i < 5; i++) {
      houses.add(House(
        position: i,
        attributes: {
          Attribute.color: colors[i],
          Attribute.nationality: nationalities[i],
          Attribute.pet: pets[i],
          Attribute.drink: drinks[i],
          Attribute.hobby: hobbies[i],
        },
      ));
    }

    return houses;
  }

  // Generate clues based on the solution
  List<Clue> _generateClues(List<House> houses, int difficulty) {
    final clues = <Clue>[];

    // Always include some basic clues
    // 1. Position clues
    clues.add(_generatePositionClue(houses, 2, Attribute.drink, 'Milk')); // Middle house drinks milk

    // 2. Same-house clues (who owns what)
    clues.addAll(_generateSameHouseClues(houses, difficulty));

    // 3. Adjacent clues
    clues.addAll(_generateAdjacentClues(houses, difficulty));

    // 4. Order clues
    clues.addAll(_generateOrderClues(houses, difficulty));

    // Shuffle and limit based on difficulty
    clues.shuffle(_random);
    final clueCount = 10 + difficulty; // 11-20 clues based on difficulty
    return clues.take(clueCount).toList();
  }

  Clue _generatePositionClue(List<House> houses, int position, Attribute attr, String value) {
    final positionName = ['first', 'second', 'middle', 'fourth', 'last'][position];

    return Clue(
      text: 'The person in the $positionName house ${_getActionText(attr, value)}.',
      type: ClueType.position,
      data: {
        'position': position,
        'attribute': attr,
        'value': value,
      },
    );
  }

  List<Clue> _generateSameHouseClues(List<House> houses, int difficulty) {
    final clues = <Clue>[];
    final maxClues = 5 + (difficulty ~/ 2);

    for (int i = 0; i < maxClues && i < houses.length; i++) {
      final house = houses[i];

      // Pick two random attributes to relate
      final attrs = Attribute.values.toList()..shuffle(_random);
      final attr1 = attrs[0];
      final attr2 = attrs[1];

      final value1 = house.attributes[attr1]!;
      final value2 = house.attributes[attr2]!;

      clues.add(Clue(
        text: 'The ${_getDescriptor(attr1, value1)} ${_getActionText(attr2, value2)}.',
        type: ClueType.same,
        data: {
          'attribute1': attr1,
          'value1': value1,
          'attribute2': attr2,
          'value2': value2,
        },
      ));
    }

    return clues;
  }

  List<Clue> _generateAdjacentClues(List<House> houses, int difficulty) {
    final clues = <Clue>[];
    final maxClues = 3 + (difficulty ~/ 3);

    for (int i = 0; i < maxClues && i < houses.length - 1; i++) {
      final house1 = houses[i];
      final house2 = houses[i + 1];

      final attr1 = Attribute.values[_random.nextInt(Attribute.values.length)];
      final attr2 = Attribute.values[_random.nextInt(Attribute.values.length)];

      final value1 = house1.attributes[attr1]!;
      final value2 = house2.attributes[attr2]!;

      final isLeftOf = _random.nextBool();
      if (isLeftOf) {
        clues.add(Clue(
          text: 'The $value1 house is directly left of the $value2 house.',
          type: ClueType.adjacent,
          data: {
            'left_attribute': attr1.name,
            'left_value': value1,
            'right_attribute': attr2.name,
            'right_value': value2,
          },
        ));
      } else {
        clues.add(Clue(
          text: 'The ${_getDescriptor(attr1, value1)} lives next to the ${_getDescriptor(attr2, value2)}.',
          type: ClueType.adjacent,
          data: {
            'attribute1': attr1.name,
            'value1': value1,
            'attribute2': attr2.name,
            'value2': value2,
          },
        ));
      }
    }

    return clues;
  }

  List<Clue> _generateOrderClues(List<House> houses, int difficulty) {
    final clues = <Clue>[];
    final maxClues = 2 + (difficulty ~/ 4);

    for (int i = 0; i < maxClues && i < houses.length; i++) {
      final house = houses[i];
      final attr = Attribute.values[_random.nextInt(Attribute.values.length)];
      final value = house.attributes[attr]!;

      if (i == 0) {
        clues.add(Clue(
          text: 'The ${_getDescriptor(attr, value)} lives in the first house.',
          type: ClueType.position,
          data: {
            'position': 0,
            'attribute': attr,
            'value': value,
          },
        ));
      } else if (i == 4) {
        clues.add(Clue(
          text: 'The ${_getDescriptor(attr, value)} lives in the last house.',
          type: ClueType.position,
          data: {
            'position': 4,
            'attribute': attr,
            'value': value,
          },
        ));
      }
    }

    return clues;
  }

  String _getDescriptor(Attribute attr, String value) {
    return switch (attr) {
      Attribute.color => '$value house owner',
      Attribute.nationality => value,
      Attribute.pet => 'person with the $value',
      Attribute.drink => 'person who drinks $value',
      Attribute.hobby => 'person who likes $value',
    };
  }

  String _getActionText(Attribute attr, String value) {
    return switch (attr) {
      Attribute.color => 'lives in the $value house',
      Attribute.nationality => 'is $value',
      Attribute.pet => 'owns a $value',
      Attribute.drink => 'drinks $value',
      Attribute.hobby => 'enjoys $value',
    };
  }
}
