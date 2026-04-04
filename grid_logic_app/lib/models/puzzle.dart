// Puzzle Model - Represents a complete logic puzzle (Einstein's riddle)
// 5 houses, each with 5 attributes: color, nationality, pet, drink, hobby

enum Attribute {
  color,
  nationality,
  pet,
  drink,
  hobby,
}

class AttributeValue {
  final Attribute attribute;
  final String value;

  const AttributeValue(this.attribute, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeValue &&
          runtimeType == other.runtimeType &&
          attribute == other.attribute &&
          value == value;

  @override
  int get hashCode => attribute.hashCode ^ value.hashCode;

  @override
  String toString() => '$attribute: $value';
}

class House {
  final int position; // 0-4
  final Map<Attribute, String> attributes;

  House({required this.position, required this.attributes});

  String? getAttribute(Attribute attr) => attributes[attr];

  bool hasAttribute(Attribute attr, String value) =>
      attributes[attr] == value;

  @override
  String toString() => 'House $position: $attributes';
}

class Clue {
  final String text;
  final ClueType type;
  final Map<String, dynamic> data;

  Clue({required this.text, required this.type, required this.data});

  @override
  String toString() => text;
}

enum ClueType {
  same, // "The British person lives in the red house"
  adjacent, // "The green house is directly left of the white house"
  position, // "The person in the middle house drinks milk"
  order, // "The Norwegian lives next to the blue house"
}

class Puzzle {
  final List<House> houses;
  final List<Clue> clues;
  final int difficulty; // 1-10

  Puzzle({
    required this.houses,
    required this.clues,
    required this.difficulty,
  });

  // Get all possible values for each attribute
  static const Map<Attribute, List<String>> possibleValues = {
    Attribute.color: ['Red', 'Green', 'Blue', 'Yellow', 'White'],
    Attribute.nationality: ['British', 'Swedish', 'Norwegian', 'Danish', 'German'],
    Attribute.pet: ['Dog', 'Cat', 'Bird', 'Fish', 'Horse'],
    Attribute.drink: ['Tea', 'Coffee', 'Milk', 'Beer', 'Water'],
    Attribute.hobby: ['Reading', 'Gaming', 'Gardening', 'Painting', 'Cooking'],
  };

  // Find the house with a specific attribute value
  House? findHouse(Attribute attr, String value) {
    for (final house in houses) {
      if (house.getAttribute(attr) == value) {
        return house;
      }
    }
    return null;
  }

  // Check if puzzle is solved correctly
  bool isSolved(Map<int, Map<Attribute, String>> playerSolution) {
    for (int i = 0; i < 5; i++) {
      for (final attr in Attribute.values) {
        if (playerSolution[i]?[attr] != houses[i].attributes[attr]) {
          return false;
        }
      }
    }
    return true;
  }

  // Get the answer to "Who owns the fish?" question
  String getAnswerNationality() {
    final fishHouse = findHouse(Attribute.pet, 'Fish');
    return fishHouse?.attributes[Attribute.nationality] ?? 'Unknown';
  }
}
