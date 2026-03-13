import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nido/widgets/tags_input_field.dart';

void main() {
  Future<void> pumpTagsField(
    WidgetTester tester, {
    required ValueChanged<List<String>> onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagsInputField(
            suggestedTags: const ['invierno', 'nuevo'],
            onChanged: onChanged,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('adds a valid tag', (tester) async {
    List<String> currentTags = const [];
    await pumpTagsField(tester, onChanged: (tags) => currentTags = tags);

    await tester.enterText(find.byType(TextField), 'algodón,');
    await tester.pump();

    expect(find.text('algodón'), findsOneWidget);
    expect(currentTags, ['algodón']);
  });

  testWidgets('does not duplicate tags case-insensitively', (tester) async {
    List<String> currentTags = const [];
    await pumpTagsField(tester, onChanged: (tags) => currentTags = tags);

    await tester.enterText(find.byType(TextField), 'Invierno,');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'invierno,');
    await tester.pump();

    expect(find.text('Invierno'), findsOneWidget);
    expect(find.text('invierno'), findsNothing);
    expect(currentTags, ['Invierno']);
  });

  testWidgets('respects maximum number of tags', (tester) async {
    List<String> currentTags = const [];
    await pumpTagsField(tester, onChanged: (tags) => currentTags = tags);

    await tester.enterText(find.byType(TextField), 'a,b,c,d,e,f,g,h,i,');
    await tester.pump();

    expect(currentTags, hasLength(kMaxTagsPerItem));
    expect(currentTags, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']);
    expect(find.text('i'), findsNothing);
  });

  testWidgets('ignores empty tag entries', (tester) async {
    List<String> currentTags = const [];
    await pumpTagsField(tester, onChanged: (tags) => currentTags = tags);

    await tester.enterText(find.byType(TextField), ', ;\n');
    await tester.pump();

    expect(currentTags, isEmpty);
    expect(find.byType(InputChip), findsNothing);
  });
}
