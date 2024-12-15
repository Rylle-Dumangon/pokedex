import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalsproject/main.dart';

void main() {
  testWidgets('SplashScreen loads and navigates', (WidgetTester tester) async {
    // Build SplashScreen and trigger a frame.
    await tester.pumpWidget(GenshinCompanionApp());

    // Verify that the splash screen is shown.
    expect(find.text('Genshin Impact Companion'), findsOneWidget);

    // Allow the splash screen to navigate to the home screen.
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify that the home screen is shown.
    expect(find.text('Genshin Characters'), findsOneWidget);
  });

  testWidgets('HomePage displays characters', (WidgetTester tester) async {
    // Mock the app and trigger a frame.
    await tester.pumpWidget(GenshinCompanionApp());

    // Navigate to the home page.
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify the presence of the character grid.
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('CharacterDetailPage shows character details', (WidgetTester tester) async {
    final mockCharacter = {
      'name': 'Aether',
      'icon': 'https://gsi.fly.dev/images/aether.png',
      'element': 'Anemo',
      'weapon': 'Sword'
    };

    // Build CharacterDetailPage and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: CharacterDetailPage(character: mockCharacter)));

    // Verify character details are displayed.
    expect(find.text('Name: Aether'), findsOneWidget);
    expect(find.text('Element: Anemo'), findsOneWidget);
    expect(find.text('Weapon: Sword'), findsOneWidget);
  });
}
