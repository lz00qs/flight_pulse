import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flight_pulse/main.dart';

void main() {
  testWidgets('FlightPulse app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FlightPulseApp()));

    // Verify that brand name exists
    expect(find.text('FlightPulse'), findsAtLeastNWidgets(1));
  });
}
