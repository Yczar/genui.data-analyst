import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  const DataTableWidget({super.key, required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            dataRowColor: MaterialStateProperty.resolveWith((states) {
              return Colors.transparent;
            }),
            columns: columns
                .map(
                  (c) => DataColumn(
                    label: Text(
                      c,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
            rows: rows.map((row) {
              return DataRow(
                cells: row.map((cell) => DataCell(Text(cell))).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
