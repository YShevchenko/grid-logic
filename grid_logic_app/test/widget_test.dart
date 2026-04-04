// Grid Logic Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_logic_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: GridLogicApp()));

    // Verify that the title is displayed
    expect(find.text('GRID LOGIC'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
