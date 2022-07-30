import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

// This widget use the Syncfusion Cartesian Chart to display the Chart
// You can explore more about this Chart at flutter.syncfusion.com
class Chart extends StatelessWidget {
  final List<Map<String, Object>> transactions;
  const Chart({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = transactions
        .map((e) => ChartData(e['date'] as DateTime, e['amount'] as double))
        .toList();
    double max = chartData.fold(
        0, (previousValue, element) => previousValue + (element.y));
    for (int i = 1; i < chartData.length; i++) {
      if (chartData[i].y > max) max = chartData[i].y;
    }
    return SfCartesianChart(
      enableAxisAnimation: true,
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryYAxis: NumericAxis(
        isVisible: false,
        maximum: max == 0 ? 10 : max + (10 / max) * max,
        numberFormat: NumberFormat.currency(symbol: 'PKR:- ', decimalDigits: 0),
      ),
      primaryXAxis: DateTimeCategoryAxis(
        dateFormat: DateFormat.E(),
      ),
      series: [
        // Renders column chart
        ColumnSeries<ChartData, DateTime>(
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.middle,
            angle: 270,
            offset: Offset(0, 5),
          ),
          animationDuration: 0,
          dataSource: chartData,
          isTrackVisible: true,
          trackColor: Theme.of(context).accentColor,
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(
    this.x,
    this.y,
  );
  final DateTime x;
  final double y;
}
