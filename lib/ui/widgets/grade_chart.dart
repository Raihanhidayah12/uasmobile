import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/grade.dart';

class GradeChart extends StatelessWidget {
  final List<Grade> grades;

  const GradeChart({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),

            /// Sumbu X (mapel)
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= grades.length) {
                      return const Text('');
                    }
                    return Text(
                      grades[index].subject,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),

            /// Data Chart
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.indigo,
                barWidth: 3,
                spots: [
                  for (int i = 0; i < grades.length; i++)
                    FlSpot(i.toDouble(), grades[i].finalScore.toDouble()),
                ],
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
