import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'DashBoard.dart';
import 'MonthlyBudget2.dart';
import 'dailyExpences.dart';

class DailyDashboard extends StatefulWidget {
  const DailyDashboard({Key? key}) : super(key: key);

  @override
  _DailyDashboardState createState() => _DailyDashboardState();
}

class _DailyDashboardState extends State<DailyDashboard> {
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateTime _fromDate = DateTime.now();
  final DateTime _toDate = DateTime.now();


  final TextEditingController monthlyincome = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();


  @override
  void initState() {
    super.initState();
   // _loadDataFromSharedPreferences();
    fetchDataFromSharedPreferences();
  }
  double _totalBudget = 0.0;

  void fetchDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? incomeIds = prefs.getStringList('totalIncomes');
    if (incomeIds != null) {
      for (String incomeId in incomeIds) {
        String? totalIncome = prefs.getString('$incomeId:totalincome');
        String? incomeType = prefs.getString('$incomeId:incomeType');
        String? selectedFromDate = prefs.getString('$incomeId:selectedFromDate');
        String? selectedToDate = prefs.getString('$incomeId:selectedToDate');
        if (totalIncome != null && incomeType != null && selectedFromDate != null && selectedToDate != null) {
          // Calculate total monthly amount for Daily Expenses
          double totalDailyExpenses = 0;
          List<String> monthlyExpenses = prefs.getStringList('$incomeId:monthlyexpenses') ?? [];
          for (String expense in monthlyExpenses) {
            var parts = expense.split(':');
            if (parts[0] == 'Daily Expenses') {
              totalDailyExpenses += double.parse(parts[1]);
            }
          }

          setState(() {
            trips.add({
              'incomeId': incomeId,
              'totalIncome': totalIncome,
              'incomeType': incomeType,
              'selectedFromDate': selectedFromDate,
              'selectedToDate': selectedToDate,
              'totalDailyExpenses': totalDailyExpenses.toStringAsFixed(2), // Convert to string and fix to 2 decimal places
            });
          });
        }
      }
    }
  }

/*
  void fetchDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? incomeIds = prefs.getStringList('totalIncomes');
    if (incomeIds != null) {
      for (String incomeId in incomeIds) {
        String? totalIncome = prefs.getString('$incomeId:totalincome');
        String? incomeType = prefs.getString('$incomeId:incomeType');
        String? selectedFromDate = prefs.getString('$incomeId:selectedFromDate');
        String? selectedToDate = prefs.getString('$incomeId:selectedToDate');
        if (totalIncome != null && incomeType != null && selectedFromDate != null && selectedToDate != null) {
          setState(() {
            trips.add({
              'incomeId': incomeId,
              'totalIncome': totalIncome,
              'incomeType': incomeType,
              'selectedFromDate': selectedFromDate,
              'selectedToDate': selectedToDate,
            });
          });
        }
      }
    }
  }
*/



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Text(
            "Daily Expensive",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DashBoard()));
            },
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
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(height: 5),
                Visibility(
                  visible: trips.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Your Budget',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return buildTripContainer(context, trips[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Set<String> displayedIncomeIds = Set();

  Widget? buildTripContainer(BuildContext context, Map<String, dynamic> trip) {
 /*   if (displayedIncomeIds.contains(trip['incomeId'])) {
      // Return an empty container if incomeId is already displayed
      return Container();
    }*/

    displayedIncomeIds.add(trip['incomeId']); // Add the incomeId to the set

    if (trip['totalDailyExpenses'] == '0.00') {
      // Return null if totalDailyExpenses is 0
      return null;
    }

    final fromDate = parseDate(trip['selectedFromDate']);
    final toDate = parseDate(trip['selectedToDate']);

    final fromFormatted = DateFormat('MMM dd').format(fromDate);
    final toFormatted = DateFormat('MMM dd, yyyy').format(toDate);

    final dateRange = '$fromFormatted → $toFormatted';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpensePage(
              incomeId: trip['incomeId'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 350,
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color(0xFF8155BA), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Daily Expenses: ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: trip['totalDailyExpenses'] ?? '0.00', // Default to 0.00 if not available
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                 /* Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Income ID: ${trip['incomeId']}', style: Theme.of(context).textTheme.labelMedium),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('$dateRange', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  ),
                ],
              ),
            /*  SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Daily Expenses: ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: trip['totalDailyExpenses'] ?? '0.00', // Default to 0.00 if not available
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),*/
              //SizedBox(height: 5,)
            ],
          ),
        ),
      ),
    );
  }

  DateTime parseDate(String dateStr) {
    // Try parsing date with different formats
    List<String> formats = [
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
    ];
    for (var format in formats) {
      try {
        return DateFormat(format).parseStrict(dateStr);
      } catch (e) {
        continue;
      }
    }
    throw ArgumentError("Invalid date format: $dateStr");
  }

}
