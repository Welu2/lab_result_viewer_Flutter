import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/appointments_user/widgets/appointments_view.dart';
import 'package:lab_result_viewer/features/appointments_user/models/appointment.dart';

void main() {
  final appt1 = Appointment(
    id: '1',
    testType: 'X-Ray',
    date: '2025-06-05',
    time: '10:00 AM',
    status: 'pending',
  );
  final appt2 = Appointment(
    id: '2',
    testType: 'Blood Work',
    date: '2025-06-03',
    time: '09:30 AM',
    status: 'scheduled',
  );

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(height: 600, child: child)),
      );

  testWidgets('empty appointments shows placeholder', (tester) async {
    await tester.pumpWidget(wrap(
      AppointmentsView(
        appointments: [],
        sortBy: 'date',
        onSortSelected: (_) {},
        onBookNew: () {},
        onReschedule: (_) {},
        onCancel: (_) {},
      ),
    ));

    expect(find.byKey(const Key('empty')), findsOneWidget);
    expect(find.text('No appointments found'), findsOneWidget);
  });

  testWidgets('renders appointments list and callbacks', (tester) async {
    String? sortedBy;
    bool booked = false;
    Appointment? rescheduled;
    String? canceledId;

    await tester.pumpWidget(wrap(
      AppointmentsView(
        appointments: [appt1, appt2],
        sortBy: 'name',
        onSortSelected: (v) => sortedBy = v,
        onBookNew: () => booked = true,
        onReschedule: (a) => rescheduled = a,
        onCancel: (id) => canceledId = id,
      ),
    ));

    // Let everything lay out
    await tester.pumpAndSettle();

    // 1) "by name" label
    expect(find.byKey(const Key('sort_label')), findsOneWidget);
    expect(find.text('by name'), findsOneWidget);

    // 2) tap sort menu → select By Date
    await tester.tap(find.byKey(const Key('sort_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('By Date').last);
    await tester.pump(); // <— allow the callback to fire
    expect(sortedBy, 'date');

    // 3) Book new button
    await tester.tap(find.byKey(const Key('book_button')));
    await tester.pump(); // <— allow the callback to fire
    expect(booked, isTrue);

    // 4) It should build two cards, sorted by name: Blood Work (id=2) then X-Ray (id=1)
    final firstTitle = find.descendant(
      of: find.byKey(const Key('card_2')),
      matching: find.text('Blood Work'),
    );
    final secondTitle = find.descendant(
      of: find.byKey(const Key('card_1')),
      matching: find.text('X-Ray'),
    );
    expect(firstTitle, findsOneWidget);
    expect(secondTitle, findsOneWidget);

    // 5) Reschedule and cancel callbacks
    await tester.tap(find.byKey(const Key('reschedule_1')));
    await tester.pump(); // <— allow the callback to fire
    expect(rescheduled, appt1);

    await tester.tap(find.byKey(const Key('cancel_2')));
    await tester.pump(); // <— allow the callback to fire
    expect(canceledId, '2');
  });
}


