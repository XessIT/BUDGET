import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartExample extends StatefulWidget {
  @override
  _PieChartExampleState createState() => _PieChartExampleState();
}

class _PieChartExampleState extends State<PieChartExample> {
  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(223, 250, 92, 1),
      Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(175, 63, 62, 1.0),
      Color.fromRGBO(254, 154, 92, 1),
    ]
  ];
  final colorList = <Color>[
    Colors.greenAccent,
  ];

  // Define variables for budget calculation
  double totalBudget = 1000; // Example total budget
  double totalSpent = 500; // Example total spent

  @override
  Widget build(BuildContext context) {
    // Calculate remaining budget
    double remainingBudget = totalBudget - totalSpent;

    // Update data map with calculated budget values
    Map<String, double> dataMap = {
      'Total Spent': totalSpent,
      'Remaining Budget': remainingBudget,
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8155BA),
        title: Text('Pie Chart Example'),
      ),
      body: Center(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          gradientList: gradientList,
          emptyColorGradient: [
            Color(0xff6c5ce7),
            Colors.blue,
          ],
          initialAngleInDegree: 0,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
        ),
      ),
    );
  }
}
