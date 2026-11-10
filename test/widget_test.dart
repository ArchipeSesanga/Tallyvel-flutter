import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/app/app.dart';

void main() {
  testWidgets('shows the Tallyvel title', (tester) async {
    await tester.pumpWidget(const TallyvelApp());

    expect(find.text('Tallyvel'), findsOneWidget);
  });
}
