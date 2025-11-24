import 'package:data_analyst/widgets/charts.dart';
import 'package:data_analyst/widgets/data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LineChartWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LineChartWidget(
            title: 'Test Line Chart',
            points: const [
              {'x': 0, 'y': 10},
              {'x': 1, 'y': 20},
              {'x': 2, 'y': 15},
            ],
            xAxisLabel: 'Time',
            yAxisLabel: 'Value',
          ),
        ),
      ),
    );

    expect(find.text('Test Line Chart'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
  });

  testWidgets('PieChartWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PieChartWidget(
            title: 'Test Pie Chart',
            sections: const [
              {'label': 'A', 'value': 40, 'color': '#FF0000'},
              {'label': 'B', 'value': 60, 'color': '#00FF00'},
            ],
          ),
        ),
      ),
    );

    expect(find.text('Test Pie Chart'), findsOneWidget);
    // FlChart might not render text as standard Text widgets in all cases, but title should be there.
  });

  testWidgets('DataTableWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataTableWidget(
            columns: const ['Col1', 'Col2'],
            rows: const [
              ['Val1', 'Val2'],
              ['Val3', 'Val4'],
            ],
          ),
        ),
      ),
    );

    expect(find.text('Col1'), findsOneWidget);
    expect(find.text('Val1'), findsOneWidget);
  });
}
