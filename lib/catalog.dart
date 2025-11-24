import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import 'widgets/charts.dart';
import 'widgets/data_table.dart';

class DataAnalystCatalog {
  static final CatalogItem lineChart = CatalogItem(
    name: 'line_chart',
    dataSchema: S.object(
      properties: {
        'title': S.string(),
        'xAxisLabel': S.string(),
        'yAxisLabel': S.string(),
        'points': S.list(
          items: S.object(
            properties: {'x': S.number(), 'y': S.number()},
            required: ['x', 'y'],
          ),
        ),
      },
      required: ['points', 'title'],
    ),
    widgetBuilder: (context) {
      final data = context.data as Map<String, dynamic>;
      return LineChartWidget(
        title: data['title'] as String,
        xAxisLabel: data['xAxisLabel'] as String?,
        yAxisLabel: data['yAxisLabel'] as String?,
        points: (data['points'] as List).cast<Map<String, dynamic>>(),
      );
    },
  );

  static final CatalogItem pieChart = CatalogItem(
    name: 'pie_chart',
    dataSchema: S.object(
      properties: {
        'title': S.string(),
        'sections': S.list(
          items: S.object(
            properties: {
              'label': S.string(),
              'value': S.number(),
              'color': S.string(description: 'Hex color code (e.g., #FF0000)'),
            },
            required: ['label', 'value'],
          ),
        ),
      },
      required: ['sections', 'title'],
    ),
    widgetBuilder: (context) {
      final data = context.data as Map<String, dynamic>;
      return PieChartWidget(
        title: data['title'] as String,
        sections: (data['sections'] as List).cast<Map<String, dynamic>>(),
      );
    },
  );

  static final CatalogItem dataTable = CatalogItem(
    name: 'data_table',
    dataSchema: S.object(
      properties: {
        'columns': S.list(items: S.string()),
        'rows': S.list(items: S.list(items: S.string())),
      },
      required: ['columns', 'rows'],
    ),
    widgetBuilder: (context) {
      final data = context.data as Map<String, dynamic>;
      return DataTableWidget(
        columns: (data['columns'] as List).cast<String>(),
        rows: (data['rows'] as List)
            .map((row) => (row as List).cast<String>())
            .toList(),
      );
    },
  );

  static Catalog get catalog {
    return CoreCatalogItems.asCatalog().copyWith([
      lineChart,
      pieChart,
      dataTable,
    ]);
  }
}
