// Test dasar untuk aplikasi Sistem Antrian Puskesmas
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_randomforest_puskesmas_benda/main.dart';

void main() {
  testWidgets('App loads landing page', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify landing page elements exist
    expect(find.text('Ambil Antrian'), findsOneWidget);
  });

  testWidgets('Landing page has hero title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify hero title contains expected text
    expect(find.textContaining('SISTEM ANTRIAN'), findsWidgets);
  });
}
