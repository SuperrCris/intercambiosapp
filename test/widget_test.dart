import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intercambioapp/main.dart';

void main() {
  testWidgets('participation bar has full-width top candy-cane stripe', (
    WidgetTester tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ParticipationBar(
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final bar = find.byType(ParticipationBar);
    final rect = tester.getRect(bar);
    final stripe = find.descendant(
      of: bar,
      matching: find.byKey(const ValueKey('candy-cane-stripe')),
    );
    expect(stripe, findsOneWidget);
    final stripeRect = tester.getRect(stripe);
    expect(stripeRect.left, rect.left);
    expect(stripeRect.right, rect.right);
    expect(stripeRect.top, rect.top + 10);
    expect(stripeRect.height, 8);
    final button = tester.widget<ElevatedButton>(
      find.descendant(of: bar, matching: find.byType(ElevatedButton)),
    );
    expect(
      tester
          .getTopLeft(
            find.descendant(of: bar, matching: find.byType(ElevatedButton)),
          )
          .dy,
      greaterThan(stripeRect.bottom),
    );
    final buttonStyle = button.style!;
    expect(buttonStyle.backgroundColor!.resolve({}), const Color(0xFFD4AF37));
    expect(
      buttonStyle.side!.resolve({}),
      const BorderSide(color: Colors.white, width: 2),
    );
    final surface = tester.widget<ColoredBox>(
      find.descendant(of: bar, matching: find.byType(ColoredBox)).first,
    );
    expect(surface.color, Colors.red);
    await tester.tap(find.text('🎁 Participar'));
    expect(pressed, isTrue);
  });

  testWidgets('festive header has only a bottom candy-cane stripe', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CandyCaneHeader(child: Text('Intercambios Gutierrada')),
        ),
      ),
    );

    expect(find.text('Intercambios Gutierrada'), findsOneWidget);
    final header = find.byType(CandyCaneHeader);
    final stripe = find.descendant(
      of: header,
      matching: find.byKey(const ValueKey('candy-cane-stripe')),
    );
    expect(stripe, findsOneWidget);
    final headerRect = tester.getRect(header);
    final stripeRect = tester.getRect(stripe);
    expect(headerRect.left, 0);
    expect(
      headerRect.right,
      tester.view.physicalSize.width / tester.view.devicePixelRatio,
    );
    expect(stripeRect.left, headerRect.left);
    expect(stripeRect.right, headerRect.right);
    expect(stripeRect.bottom, headerRect.bottom);
    expect(stripeRect.height, 8);
  });

  testWidgets('registration uses a dark green background and readable text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistrationPage()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF003510));
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final title = appBar.title! as Text;
    expect(title.data, 'Carta de Navidad');
    expect(title.style?.fontFamily, 'Fortalesa');
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.style?.color, const Color(0xFF3E2723));
    expect(field.decoration?.hintStyle?.color, const Color(0xFF9E8A7A));
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .whereType<CustomPainter>()
        .firstWhere(
          (painter) =>
              painter.runtimeType.toString() == '_ChristmasBackgroundPainter',
        );
    expect(
      (Canvas canvas) => painter.paint(canvas, const Size(300, 600)),
      paints..rect(color: const Color(0xFF003510)),
    );
  });

  testWidgets('participant heading follows the loaded count', (tester) async {
    final completer = Completer<Map<String, dynamic>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ParticipantsSection(future: completer.future)),
      ),
    );
    expect(find.text('Personas especiales'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete({
      for (var i = 0; i < 22; i++)
        '$i': {'nombre': 'Participante $i', 'photoUrl': null},
    });
    await tester.pumpAndSettle();
    expect(find.text('22 personas especiales'), findsOneWidget);
    expect(find.textContaining('Total:'), findsNothing);
    expect(find.text('Participante 0'), findsOneWidget);
  });

  testWidgets('participant heading uses singular and zero correctly', (
    tester,
  ) async {
    Future<void> showParticipants(Map<String, dynamic> participants) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticipantsSection(future: Future.value(participants)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showParticipants({});
    expect(find.text('0 personas especiales'), findsOneWidget);
    expect(find.text('Aún no hay participantes'), findsOneWidget);
    await showParticipants({
      '1': {'nombre': 'Una persona', 'photoUrl': null},
    });
    expect(find.text('1 persona especial'), findsOneWidget);
    expect(find.text('Una persona'), findsOneWidget);
  });

  testWidgets('participant errors do not display a count', (tester) async {
    final completer = Completer<Map<String, dynamic>>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ParticipantsSection(future: completer.future)),
      ),
    );
    completer.completeError('sin conexión');
    await tester.pumpAndSettle();
    expect(find.text('Personas especiales'), findsOneWidget);
    expect(
      find.text('Error al cargar participantes: sin conexión'),
      findsOneWidget,
    );
  });
}
