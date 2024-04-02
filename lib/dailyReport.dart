import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'DashBoard.dart';

class DailyReportPage extends StatefulWidget {
  @override
  _DailyReportPageState createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  List<dynamic> expenses = [];
  String url =
      'http://localhost/mybudget/lib/BUDGETAPI/dailyexpensesdashboard.php';

  Future<void> fetchExpenses() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        expenses = json.decode(response.body);
        print("Expenses Body: $expenses");
        // readRecords(expenses["incomeId"]);
      });
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  @override
  void initState() {
    super.initState();
    // Example date range: from yesterday to today
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));
    String fromDate = DateFormat('yyyy-MM-dd').format(yesterday);
    String toDate = DateFormat('yyyy-MM-dd').format(now);
    fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: Text(
            "Daily Expense",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthExpensesPage(
                      incomeId: expenses[index]['incomeId'],
                      amount: expenses[index]['totalAmount']),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8155BA),
                    Colors.lightBlueAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'From Date: ${expenses[index]['fromDate'] ?? 'N/A'}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'To Date: ${expenses[index]['toDate'] ?? 'N/A'}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Total Budget: ₹${expenses[index]['totalAmount'] ?? 'N/A'}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MonthExpensesPage extends StatefulWidget {
  final String incomeId;
  final String amount;

  MonthExpensesPage({required this.incomeId, required this.amount});

  @override
  _MonthExpensesPageState createState() => _MonthExpensesPageState();
}

class _MonthExpensesPageState extends State<MonthExpensesPage> {
  List<List<dynamic>> _groupedExpenses = [];

  Future<void> readRecords(String incomeId) async {
    var url =
        'http://localhost/mybudget/lib/BUDGETAPI/dailyexpense.php'; // Replace with your actual URL
    var modifiedUrl =
        Uri.parse(url).replace(queryParameters: {'incomeId': incomeId});

    var response = await http.get(modifiedUrl);

    if (response.statusCode == 200) {
      final expenses = jsonDecode(response.body);

      // Group expenses by date
      _groupedExpenses = groupExpensesByDate(expenses);

      setState(() {}); // Trigger a rebuild after grouping expenses
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  // Helper function to group expenses by date
  List<List<dynamic>> groupExpensesByDate(List<dynamic> expenses) {
    Map<String, List<dynamic>> groupedMap = {};

    for (var expense in expenses) {
      String date = expense['date'];
      groupedMap.putIfAbsent(date, () => []);
      groupedMap[date]!.add(expense);
    }

    return groupedMap.values.toList();
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  ///get wallet

  String wallet = '';
  Future<void> getwallet(String uid, BuildContext context) async {
    var url =
        'http://localhost/mybudget/lib/BUDGETAPI/dailyexpensescalculation.php';
    var modifiedUrl = Uri.parse(url).replace(queryParameters: {'uid': uid});

    var response = await http.get(modifiedUrl);

    if (response.statusCode == 200) {
      print(url);
      print('uid : $uid');

      // Parse the JSON response as a map directly
      var responseBody = jsonDecode(response.body);

      if (responseBody is List && responseBody.isNotEmpty) {
        // Assuming the response is a list of wallet data
        var firstRecord = responseBody.first;
        if (firstRecord.containsKey('wallet')) {
          String walletAmount = firstRecord['wallet'];
          setState(() {
            wallet = walletAmount;
          });

          // Show the alert with wallet amount
        } else {
          print('Wallet data not found in the response');
        }
      } else {
        print('Invalid or empty response format');
      }
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var group in _groupedExpenses) {
      for (var expense in group) {
        totalAmount += double.parse(expense['remaining'] ?? '0');
      }
    }
    return totalAmount;
  }

  double _totalBudget = 0.0; // Add a variable to store the total budget

  @override
  void initState() {
    super.initState();
    _groupedExpenses = [];
    readRecords(widget.incomeId.toString()); // Convert incomeId to String
    _totalBudget =
        double.parse(widget.amount); // Parse the budget amount from the widget
  }

// Calculate total spent and remaining amounts
  Map<String, double> calculateSpentAndRemainingAmount() {
    double totalSpent = 0.0;
    for (var group in _groupedExpenses) {
      for (var expense in group) {
        totalSpent += double.parse(
            expense['amount'] ?? '0'); // Add expense amount to total spent
      }
    }
    double remainingAmount =
        _totalBudget - totalSpent; // Calculate remaining amount
    return {'spent': totalSpent, 'remaining': remainingAmount};
  }

  @override
  Widget build(BuildContext context) {
    // Inside the build method, calculate spent and remaining amounts
    Map<String, double> amounts = calculateSpentAndRemainingAmount();

    return Scaffold(
      //backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: Text(
            "Daily Expense",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DailyReportPage()));
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Amount Detailes",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Expenses Budget', // Display total budget
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.left),
                          Text(
                              '₹${_totalBudget.toStringAsFixed(2)}', // Display total budget with .00 format
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.right),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Spent Expenses', // Display total spent
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.left),
                          Text(
                              '₹${amounts['spent']?.toStringAsFixed(2)}', // Display total spent with .00 format
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.right),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 1,
                          width: 70,
                          color: Colors.grey, // Small line color
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Remaining Amount\n(Wallet)', // Display remaining amount
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.left),
                          Text(
                              '₹${amounts['remaining']?.toStringAsFixed(2)}', // Display remaining amount with .00 format
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              textAlign: TextAlign.right),
                        ],
                      ),

                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 1,
                          width: 70,
                          color: Colors.grey, // Small line color
                        ),
                      ),
                      SizedBox(height: 8),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text('Wallet', // Display wallet amount
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .bodySmall
                      //             ?.copyWith(color: Colors.black),
                      //         textAlign: TextAlign.left),
                      //     Text('₹1000.00', // Display wallet amount
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .bodySmall
                      //             ?.copyWith(color: Colors.black),
                      //         textAlign: TextAlign.right),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Expenses",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _groupedExpenses.length,
                  itemBuilder: (context, dateIndex) {
                    final expensesForDate = _groupedExpenses[dateIndex];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(expensesForDate.first['date'])}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expensesForDate.length,
                          itemBuilder: (context, expenseIndex) {
                            final expense = expensesForDate[expenseIndex];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Add divider for all expenses except the first one
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${expense['category'] ?? 'N/A'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black),
                                        textAlign: TextAlign.left),
                                    Text('₹${expense['amount'] ?? 'N/A'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black),
                                        textAlign: TextAlign.right),
                                  ],
                                ),
                                SizedBox(height: 5),
                                if (expense['remarks'] != null &&
                                    expense['remarks'].isNotEmpty)
                                  Text(
                                    'Remarks: ${expense['remarks']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.black),
                                  ),
                              ],
                            );
                          },
                        ),
                        Divider(),
                        // SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
