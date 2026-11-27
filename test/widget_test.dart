
import 'package:flutter_test/flutter_test.dart';

import 'package:sharetrip_student_and_driver/main.dart';

void main() {
  testWidgets('ShareTrip app loads successfully',
      (WidgetTester tester) async {

    await tester.pumpWidget(const ShareTripApp());

    expect(find.text('ShareTrip'), findsWidgets);
  });
}
