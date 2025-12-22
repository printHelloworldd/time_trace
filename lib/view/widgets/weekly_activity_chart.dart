import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';

class WeeklyActivityChart extends StatelessWidget {
  final Map<String, Map<CategoryModel, int>> weeklyStats;
  final List<CategoryModel> categories;

  const WeeklyActivityChart({
    super.key,
    required this.weeklyStats,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: LineChart(
          _createChartData(),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }

  LineChartData _createChartData() {
    return LineChartData(
      lineTouchData: _lineTouchData,
      gridData: _gridData,
      titlesData: _titlesData,
      borderData: _borderData,
      lineBarsData: _createLineBars(),
      minX: 0,
      maxX: 6, // 7 days (0-6)
      maxY: _calculateMaxY(),
      minY: 0,
    );
  }

  // Tooltips on click
  LineTouchData get _lineTouchData => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: 0.8),
      getTooltipItems: (touchedSpots) {
        return touchedSpots.map((spot) {
          final categoryIndex = spot.barIndex;
          if (categoryIndex >= categories.length) return null;

          final category = categories[categoryIndex];
          return LineTooltipItem(
            '${category.title}\n${spot.y.toInt()} ч',
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList();
      },
    ),
  );

  // Axis titles
  FlTitlesData get _titlesData => FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: _bottomTitleWidgets,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 4,
        reservedSize: 40,
        getTitlesWidget: _leftTitleWidgets,
      ),
    ),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  // Days of the week on the X axis
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final text = value.toInt() < dayNames.length ? dayNames[value.toInt()] : '';

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(text, style: style),
    );
  }

  // Hours on the Y axis
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    return SideTitleWidget(
      meta: meta,
      child: Text('${value.toInt()}h', style: style),
    );
  }

  // Grid
  FlGridData get _gridData => FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: 4,
    getDrawingHorizontalLine: (value) {
      return FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1);
    },
  );

  // Frame
  FlBorderData get _borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 2),
      left: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 2),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );

  // Creates lines for each category
  List<LineChartBarData> _createLineBars() {
    final lines = <LineChartBarData>[];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final spots = _createSpotsForCategory(category);

      if (spots.isNotEmpty) {
        lines.add(
          LineChartBarData(
            isCurved: true,
            color: category.color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: category.color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: category.color.withValues(alpha: 0.1),
            ),
            spots: spots,
          ),
        );
      }
    }

    return lines;
  }

  // Creates points for a specific category
  List<FlSpot> _createSpotsForCategory(CategoryModel category) {
    final spots = <FlSpot>[];
    final sortedDates = weeklyStats.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length && i < 7; i++) {
      final date = sortedDates[i];
      final categoryStats = weeklyStats[date];
      final count = categoryStats?[category] ?? 0;

      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    return spots;
  }

  // Calculates the maximum value of Y
  double _calculateMaxY() {
    double maxValue = 0;

    weeklyStats.forEach((date, categoryStats) {
      categoryStats.forEach((category, count) {
        if (count > maxValue) {
          maxValue = count.toDouble();
        }
      });
    });

    // Adds some extra on top
    return (maxValue + 4).ceilToDouble();
  }
}
