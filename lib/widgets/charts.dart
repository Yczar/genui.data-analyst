import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.title,
    required this.points,
    this.xAxisLabel,
    this.yAxisLabel,
  });

  final String title;
  final List<Map<String, dynamic>> points;
  final String? xAxisLabel;
  final String? yAxisLabel;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = points.map((p) {
      return FlSpot((p['x'] as num).toDouble(), (p['y'] as num).toDouble());
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal height based on width, but cap it
        final double chartHeight = (constraints.maxWidth * 0.6).clamp(
          200.0,
          400.0,
        );

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: chartHeight,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          axisNameWidget: xAxisLabel != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    xAxisLabel!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )
                              : null,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: yAxisLabel != null
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    yAxisLabel!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )
                              : null,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<Map<String, dynamic>> sections;

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> pieSections = sections.map((s) {
      final colorHex = s['color'] as String?;
      final color = colorHex != null
          ? Color(int.parse(colorHex.replaceFirst('#', '0xFF')))
          : Colors.primaries[sections.indexOf(s) % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: (s['value'] as num).toDouble(),
        title: s['label'] as String,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal height based on width, but cap it
        final double chartHeight = (constraints.maxWidth * 0.6).clamp(
          200.0,
          400.0,
        );

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: chartHeight,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 4,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events if needed
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
