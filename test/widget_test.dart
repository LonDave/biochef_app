import 'package:flutter_test/flutter_test.dart';
import 'package:biochef_app/main.dart';

void main() {
  testWidgets('Verifica caricamento schermata registrazione', (
    WidgetTester tester,
  ) async {
    // Carica l'app usando il nuovo nome della classe: BioChefApp
    await tester.pumpWidget(const BioChefApp());

    // Verifica che appaia il testo della schermata di registrazione
    expect(find.text('Registrazione Admin'), findsOneWidget);
  });
}
