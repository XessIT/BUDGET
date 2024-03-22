import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:simple_icons/simple_icons.dart';


import 'DashBoard.dart';

class DailyReportPage extends StatefulWidget {
  @override
  _DailyReportPageState createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  List<Map<String, String>> _savedDetails = [];
  double _totalBudget = 0.0; // Add this variable in your _ReportPageState class

  @override
  void initState() {
    super.initState();
    Dailyexpenceloaddata();
    _loadDataFromSharedPreferences();
  }

  List<Map<String, dynamic>> trips = [];

  Future<void> _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> incomeIds = prefs.getStringList('incomeIds') ?? [];

    List<Map<String, dynamic>> loadedTrips = [];

    for (String incomeId in incomeIds) {
      List<String> monthlyExpenses =
          prefs.getStringList('$incomeId:monthlyexpenses') ?? [];
      List<String>? notes = prefs.getStringList('$incomeId:notes') ?? [];

      List<Map<String, dynamic>> expenses = monthlyExpenses.map((expense) {
        var parts = expense.split(':');
        return {
          'monthcategory': parts[0],
          'monthlyamount': double.parse(parts[1]),
          'date': parts[2],
          'remarks': parts[3],
        };
      }).toList();

      loadedTrips.add({'expenses': expenses, 'notes': notes});
    }

    // Calculate total monthly amount for Daily Expenses
    for (var trip in loadedTrips) {
      for (var expense in trip['expenses']) {
        if (expense['monthcategory'] == 'Daily Expences') {
          _totalBudget += expense['monthlyamount'];
        }
      }
    }

    print('Total Monthly Amount for Daily Expenses: $_totalBudget');

    setState(() {
      trips = loadedTrips;
    });
  }

  Future<void> Dailyexpenceloaddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedDetailsJson = prefs.getStringList('savedDetails');
    if (savedDetailsJson != null) {
      List savedDetailsDynamic =
      savedDetailsJson.map((expense) => jsonDecode(expense)).toList();
      List<Map<String, String>> savedDetails = [];
      savedDetailsDynamic.forEach((dynamic item) {
        Map<String, String> expenseMap = {};
        item.forEach((key, value) {
          expenseMap[key] = value.toString();
        });
        savedDetails.add(expenseMap);
      });

      // Retrieve the total budget from SharedPreferences
      double totalBudget = prefs.getDouble('totalBudget') ?? 0.0;

      setState(() {
        _savedDetails = savedDetails;
        // Assign the retrieved total budget value
        // Print the value here
      });
    } else {
      // Handle the case where savedDetailsJson is null (no data found)
      print('No saved details found in SharedPreferences.');
    }
  }

  List<Map<String, String>> _filterExpensesByMonth(DateTime month) {
    return _savedDetails.where((expense) {
      DateTime expenseDate = DateFormat('dd-MM-yyyy').parse(expense['Date']!);
      return expenseDate.month == month.month && expenseDate.year == month.year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> monthsWithExpenses = _getMonthsWithExpenses();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Expenses Report",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
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
      body: ListView.builder(
        itemCount: monthsWithExpenses.length,
        itemBuilder: (context, index) {
          DateTime currentMonth = monthsWithExpenses[index];
          List<Map<String, String>> expensesForMonth =
          _filterExpensesByMonth(currentMonth);
          double totalExpenses = 0.0;
          for (var expense in expensesForMonth) {
            totalExpenses += double.parse(expense['Amount']!);
          }
          String monthName = DateFormat('MMMM yyyy').format(currentMonth);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthExpensesPage(
                    monthName: monthName,
                    expenses: expensesForMonth,
                    totalBudget: _totalBudget,
                  ),
                ),
              );
            },
            child: GlassContainer(
              margin: EdgeInsets.only(left: 20, right: 20, top: 10),
              height: 120,
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      monthName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                        'Total Budget: ₹${_totalBudget.toStringAsFixed(2)}', // Display total budget here
                        style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(height: 5.0),
                    Text('Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DateTime> _getMonthsWithExpenses() {
    List<DateTime> monthsWithExpenses = [];
    Set<String> uniqueMonths = Set<String>();
    _savedDetails.forEach((expense) {
      DateTime expenseDate = DateFormat('dd-MM-yyyy').parse(expense['Date']!);
      String monthYear = DateFormat('MM-yyyy').format(expenseDate);
      uniqueMonths.add(monthYear);
    });
    uniqueMonths.forEach((monthYear) {
      List<String> split = monthYear.split('-');
      int month = int.parse(split[0]);
      int year = int.parse(split[1]);
      monthsWithExpenses.add(DateTime(year, month));
    });
    return monthsWithExpenses;
  }
}





class MonthExpensesPage extends StatefulWidget {
  final String monthName;
  final List<Map<String, String>> expenses;
  final double totalBudget; // Add this variable to accept total budget

  MonthExpensesPage({
    required this.monthName,
    required this.expenses,
    required this.totalBudget, // Update the constructor
  });

  @override
  _MonthExpensesPageState createState() => _MonthExpensesPageState();
}
class _MonthExpensesPageState extends State<MonthExpensesPage> {
  String? selectedDate;
  late List<Map<String, String>> filteredExpenses;
  Map<String, List<Map<String, String>>> groupedExpenses = {};


  String? _selectedDate; // Initialize _selectedDate here

  @override
  void initState() {
    super.initState();
    // Initialize filteredExpenses with widget.expenses
    filteredExpenses = widget.expenses;
    _selectedDate = '';
    groupExpensesByDate();

  }

  String _formatDate(String date) {
    DateTime dateTime = DateFormat('dd-MM-yyyy').parse(date);
    return DateFormat('MMM-dd').format(dateTime);
  }

  //String? _selectedDate; // Define _selectedDate variable here
  void filterExpenses(String date) {
    setState(() {
      selectedDate = date;
      filteredExpenses = widget.expenses
          .where((expense) => _formatDate(expense['Date']!) == date)
          .toList();
    });
  }

  void groupExpensesByDate() {
    groupedExpenses.clear();
    Set<String> uniqueDates = Set<String>();
    for (var expense in filteredExpenses) {
      String date = _formatDate(expense['Date']!);
      if (!groupedExpenses.containsKey(date) && !uniqueDates.contains(date)) {
        groupedExpenses[date] = [];
        uniqueDates.add(date);
      }
      groupedExpenses[date]!.add(expense);
    }
  }


  double getTotalSpentAmount() {
    double totalAmount = 0.0;
    for (var expense in filteredExpenses) {
      totalAmount += double.parse(expense['Amount']!);
    }
    return totalAmount;
  }

  double getRemainingAmount() {
    double remaining = widget.totalBudget - getTotalSpentAmount();
    return remaining > 0 ? remaining : 0.0;
  }

  double getDebitAmount() {
    double debit = getTotalSpentAmount() - widget.totalBudget;
    return debit > 0 ? debit : 0.0;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfff4f4fc
      ),
      appBar: AppBar(
        title: Text(
          widget.monthName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DailyReportPage()));
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
      body: FutureBuilder(
        future: Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                   /* Center(
                      child: Text(
                        'Total Budget: ₹${widget.totalBudget.toStringAsFixed(2)}', // Display total budget here
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                    ),   /// Total Budget*/


                  /*  Center(
                      child: Text(
                        'Total Spent Amount: Rs ₹${getTotalSpentAmount().toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),*/   /// Total Spent Amount Rs
                    SizedBox(height: 10.0),
                   /* if (getRemainingAmount() > 0 && getDebitAmount() <= 0)
                      Center(
                        child: Text(
                          'Remaining Amount: ₹${getRemainingAmount().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),  /// Remaining Amount
                    SizedBox(height: 10.0),
                    if (getDebitAmount() > 0 && getRemainingAmount() <= 0)
                      Center(
                        child: Text(
                          'Debit Amount: ₹${getDebitAmount().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),*/
                    /// Debit Amount
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20), // Set border radius to 20
                      ),
                      child: Column(
                        children: [


                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  child: Icon(SimpleIcons.affine, color: Colors.white),
                                  backgroundColor: Colors.teal, // Set the background color of the circle avatar
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start, // Align the text widgets in the center
                                    children: [
                                      Text('Budget',style: Theme.of(context).textTheme.labelMedium),
                                      SizedBox(width: 30,),
                                      Text(
                                        '₹${widget.totalBudget.toStringAsFixed(2)}' ,style: Theme.of(context).textTheme.labelMedium, // Display total budget here,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2), // Add space between the row and the text widgets
                                  Container(
                                    width: 250, // Set the desired width
                                    child: LinearProgressIndicator(
                                      value: widget.totalBudget != 0 ? 1.0 : 0.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                    ),
                                  )
                                ],
                              ),// Adjust the space between the icon and progress bar
                            ],
                          ),   /// Budget
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  child: Icon(SimpleIcons.cashapp, color: Colors.white),
                                  backgroundColor: Colors.red, // Set the background color of the circle avatar
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start, // Align the text widgets in the center
                                    children: [
                                      Text('Spent',style: Theme.of(context).textTheme.labelMedium),
                                      SizedBox(width: 30,),
                                      Text(
                                        '₹${getTotalSpentAmount().toStringAsFixed(2)}' ,style: Theme.of(context).textTheme.labelMedium, // Display total budget here,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2), // Add space between the row and the text widgets
                                  Container(
                                    width: 250, // Set the desired width
                                    child: LinearProgressIndicator(
                                      value: getTotalSpentAmount() ,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    ),
                                  )
                                ],
                              ),// Adjust the space between the icon and progress bar
                            ],
                          ),


                          // Add other rows with CircleAvatar and LinearProgressIndicator here
                        ],
                      ),
                    ),

                    SizedBox(height: 10,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              filterExpenses(DateFormat('MMM-dd').format(pickedDate));
                              groupExpensesByDate();
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: Colors.teal,), // Calendar icon
                              SizedBox(width: 5), // Spacer between icon and text
                              Text(selectedDate ?? 'filter a date', style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic
                              ),), // Text
                            ],
                          ),
                        ),

                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: groupedExpenses.entries.map((entry) {
                        String date = entry.key;
                        List<Map<String, String>> expenses = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                date,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];
                                return Container(
                                  height: 50,
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:Colors.white,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 0,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        expense['Category']!,
                                      style: Theme.of(context).textTheme.bodySmall,

                                      ),

                                      Text(
                                        '₹${double.parse(expense['Amount']!).toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),  /// Separted By date container

                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
