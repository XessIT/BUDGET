import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glass_kit/glass_kit.dart';

class MonthlyReportPage extends StatefulWidget {
  @override
  _MonthlyReportPageState createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<String> incomeIds = [];

  @override
  void initState() {
    super.initState();
    _loadReportIds();
  }

  Future<void> _loadReportIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      incomeIds = prefs.getStringList('incomeIds') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Budget Reports",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color(0xFF8155BA),
      ),
      body: ListView.builder(
        itemCount: incomeIds.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _getReportData(incomeIds[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return _buildReportCard(snapshot.data!, context);
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getReportData(String incomeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? totalIncome = prefs.getString('$incomeId:totalincome');
    String? incomeType = prefs.getString('$incomeId:incomeType');
    String? fromDate = prefs.getString('$incomeId:selectedFromDate');
    String? toDate = prefs.getString('$incomeId:selectedToDate');
    String? creditAmt = prefs.getString('$incomeId:creditAmt');
    String? incomeTypeMonth = prefs.getString('$incomeId:incomeTypeMonth');
    List<String>? expensesList = prefs.getStringList('$incomeId:expenses');
    List<String>? spentExpensesList = prefs.getStringList('$incomeId:monthlyexpenses');

    // Fetch additional monthly expenses data
    List<Map<String, String>> formattedExpenses = spentExpensesList?.map((expense) {
      var parts = expense.split(':');
      return {
        'monthcategory': parts[0],
        'monthlyamount': parts[1],
        'date': parts[2],
        'remarks': parts[3]
      };
    }).toList() ?? [];

    // Prepare the data
    Map<String, dynamic> reportData = {
      'totalincome': totalIncome,
      'incomeType': incomeType,
      'selectedFromDate': fromDate,
      'selectedToDate': toDate,
      'creditAmt': creditAmt,
      'incomeTypeMonth': incomeTypeMonth,
      'monthlyExpenses': formattedExpenses, // Add the fetched monthly expenses data
    };

    return reportData;
  }

  Widget _buildReportCard(Map<String, dynamic> data, BuildContext context) {
    String totalIncomes = data['totalincome'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyReport(reportData: data),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: GlassContainer(
          height: 100,
          width: double.infinity,
          gradient: LinearGradient(
            colors: [
              Color(0xFF8155BA),
              Colors.lightBlueAccent
            ], // Example gradient
          ),
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          borderWidth: 0,
          borderColor: Colors.transparent,
          frostedOpacity: 0.1,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${data['selectedFromDate'] ?? ''} - ${data['selectedToDate']??''}',
                          style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: 10),
                      Text('Total Incomes : ₹${double.parse(totalIncomes).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MonthlyReport extends StatelessWidget {
  final Map<String, dynamic> reportData;

  MonthlyReport({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Column(
              children: [
                Text( 'Monthly Report',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${reportData['selectedFromDate'] ?? ''} - ${reportData['selectedToDate']??''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color(0xFF8155BA),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF8155BA)),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildReportContent(context),
          ),
        ),
      ),
    );
  }
  Widget _buildReportContent(BuildContext context) {
    String? totalIncome = reportData['totalincome'];
    String? incomeType = reportData['incomeType'];
    String? fromDate = reportData['selectedFromDate'];
    String? toDate = reportData['selectedToDate'];
    String? creditAmt = reportData['creditAmt'];
    List<Map<String, String>> monthlyExpenses = List<Map<String, String>>.from(reportData['monthlyExpenses'] ?? []);
    double totalSpent = 0;
    for (var expense in monthlyExpenses) {
      totalSpent += double.parse(expense['monthlyamount'] ?? '0');
    }

    // Calculate remaining amount
    double remaining = double.parse(totalIncome ?? '0') - totalSpent;

    bool isDebit = remaining < 0;
    double remainingAbs = remaining.abs();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Income",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 50,),
            Text(
              "Spent",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 50,),
            Text(
              "Remaining",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Text('₹$totalIncome',style: TextStyle(color: Colors.green.shade900,fontSize: 20),),
            SizedBox(width: 50,),
            Text('₹$totalSpent',style: TextStyle(color: Colors.green.shade900,fontSize: 20),),
            SizedBox(width: 50,),
            isDebit
                ? Row( // Wrap "Debit" text in a column for smaller size
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹$remainingAbs",
                  style: TextStyle(color: Colors.green.shade900, fontSize: 20),
                ),
                const Text(
                  "Debit",
                  style: TextStyle(color: Colors.red, fontSize: 12), // Specify smaller font size for "Debit"
                ),
              ],
            )
                : Text(
              "₹$remaining",
              style: TextStyle(color: Colors.green.shade900, fontSize: 20),
            ),
          ],
        ),

        Divider(),
        Text(
          "Spent",
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        // Display monthly expenses
        for (var expense in monthlyExpenses)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${expense['date']}'),
                  Text('${expense['monthcategory']}'),
                  Text('₹${expense['monthlyamount']}'),
                ],
              ),
              SizedBox(height: 4),
              Text('${expense['remarks']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Divider(),
            ],
          ),
      ],
    );
  }


}
