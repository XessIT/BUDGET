import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/monthlyDahboard.dart';
import 'package:mybudget/spent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'DashBoard.dart';

class MonthlyBudget2 extends StatefulWidget {

  final String incomeId;

  const MonthlyBudget2({super.key,
    required this.incomeId,

  });


  @override
  State<MonthlyBudget2> createState() => _MonthlyBudget2State();
}

class _MonthlyBudget2State extends State<MonthlyBudget2> {

  final TextEditingController monthlyincome = TextEditingController();
  final TextEditingController income = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();
  final TextEditingController incomeType = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  List<Map<String, TextEditingController>> monthlyexpenses = [];
  List<Map<String, dynamic>> trips = [];
  List<String> notesList = [];

  String? errormsg = '';

  DateTime _selectedDate = DateTime.now();


  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void _updateBackendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tripId = widget.incomeId;

    // Convert the updated expenses list to a format suitable for SharedPreferences
    List<String> updatedExpenses = trips
        .map<List<String>>((trip) => trip['expenses']
        .map<String>((expense) =>
    "${expense['monthcategory']}:${expense['monthlyamount']}:${expense['date']}:${expense['remarks']}")
        .toList())
        .expand<String>((x) => x)
        .toList();

    // Update the expenses data in SharedPreferences
    prefs.setStringList('$tripId:monthlyexpenses', updatedExpenses);
  }  /// this for after delete using Update coding


  void _deleteExpense(int tripIndex, int expenseIndex) {
    setState(() {
      trips[tripIndex]['expenses'].removeAt(expenseIndex);
    });
    _updateBackendData();
  }
  double calculateTotalSpentAmount(List trips) {
    double totalSpentAmount = 0.0;
    for (var trip in trips) {
      for (var expense in trip['monthlyexpenses']) {
        // Convert the string to double before adding to totalSpentAmount
        totalSpentAmount += double.parse(expense['monthlyamount']);
      }
    }
    return totalSpentAmount;
  }

  double totalspentBudget = 0.0;
  double totalspentbudget2 = 0.0;

  double totalExpenses = 0.0;
  double totalIncome = 0.0;


  void _loadDataForMonthly() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String incomeTypeKey = '${widget.incomeId}:incomeType';
    String totalIncomeKey = '${widget.incomeId}:totalincome';
    String fromDateKey = '${widget.incomeId}:selectedFromDate';
    String toDateKey = '${widget.incomeId}:selectedToDate';

    setState(() {
      monthlyincome.text = prefs.getString(totalIncomeKey) ?? '';
      monthlyincomeType.text = prefs.getString(incomeTypeKey) ?? '';
      fromDate.text = prefs.getString(fromDateKey) ?? '';
      toDate.text = prefs.getString(toDateKey) ?? '';
    });
  }

  void _saveDataToSharedPreferences(double remainingOrDebit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String incomeId = widget.incomeId;

    List<String> incomeIds = prefs.getStringList(widget.incomeId) ?? [];
    double total = (totalAmountPerson - remainingOrDebit.abs()).abs();

    // Convert the total to a string with 2 decimal places
    String totalString = total.toStringAsFixed(2);
    Map<String, double> expensesMap = Map<String, double>.from(
        prefs.getStringList('$incomeId:monthlyexpenses')?.fold({}, (prev, element) {
          var parts = element.split(':');
          prev?[parts[0]] = double.parse(parts[1]);
          return prev;
        }) ?? {});
    List<String>? savedNotes = prefs.getStringList('$incomeId:notes') ?? [];
    List<Map<String, String>> formattedExpenses = monthlyexpenses.map((expense) {
      return {
        'monthcategory': expense['monthcategory']!.text,
        'monthlyamount': expense['monthlyamount']!.text,
        'date': expense['date']!.text,
        'remarks': expense['remarks']!.text
      };
    }).toList();

    List<String> existingExpenses =
        prefs.getStringList('$incomeId:monthlyexpenses') ?? [];
    existingExpenses.addAll(formattedExpenses.map((e) =>
    "${e['monthcategory']}:${e['monthlyamount']}:${e['date']}:${e['remarks']}"));

    // Save the updated data
    prefs.setStringList('$incomeId:monthlyexpenses', existingExpenses);
    prefs.setDouble('$incomeId:totalSpentMonth', double.parse(totalspentBudget.toStringAsFixed(2)));
    prefs.setString('$incomeId:totalRemaining', 'Total: ₹$totalString');


    // Save notes
    if (notesList.isNotEmpty) {
      savedNotes.addAll(notesList);
      prefs.setStringList('$incomeId:notes', savedNotes);
    }

    if (!incomeIds.contains(incomeId)) {
      incomeIds.add(incomeId);
      prefs.setStringList('incomeIds', incomeIds);
    }
    print('Income ID: $incomeId');
    print('Monthly Expenses:');
    print("notesList$notesList");
    print("notesList$totalString");


  }


  void _saveDataToSharedPreferencesCredit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String incomeId = widget.incomeId;
    String totalincome = income.text;
    String totalincomeType = incomeType.text;

    double currentMonthlyIncome = double.tryParse(monthlyincome.text.toString()) ?? 0.0;
    double creditAmt = double.tryParse(totalincome) ?? 0.0;
    double updatedMonthlyIncome = currentMonthlyIncome + creditAmt;

    prefs.setString('${widget.incomeId}:creditAmt', totalincome);
    prefs.setString('${widget.incomeId}:incomeTypeMonth', totalincomeType);
    prefs.setString('${widget.incomeId}:totalincome', updatedMonthlyIncome.toString());

    List<String> totalIncomes = prefs.getStringList('totalIncomes') ?? [];
    totalIncomes.add(incomeId);
    prefs.setStringList('totalIncomes', totalIncomes);

    print('Income ID: $incomeId');
    print('Total income: $totalincome');
    print('Income Type: $totalincomeType');
  }



  double _calculateTotalBudget(List monthly) {
    double totalBudgetAmount = 0.0;
    for (var month in monthly) {
      if (month.containsKey('expenses') && month['expenses'] is List) {
        for (var expense in month['expenses']) {
          totalBudgetAmount += (expense['monthlyamount'] ?? 0).toDouble();
        }
      }
    }

    return totalBudgetAmount;
  }
  double totalAmountPerson = 0.00;

  String _updateTotalBudget2() {
    totalAmountPerson = 0.00;
    for (var expense2 in monthlyexpenses) {
      double amount = double.tryParse(expense2['monthlyamount']!.text) ?? 0.0;
      totalAmountPerson += amount;
    }
    return totalAmountPerson.toStringAsFixed(2);
  }

  void updatetotalspent() {
    totalspentBudget = 0.0;
    double totalmonthlyamount = 0.0;
    for (var trip in trips) {
      for (var expense in trip['expenses']) {
        // Convert the string to double before adding to totalmonthlyamount
        totalspentBudget += double.parse(expense['monthlyamount']);
      }
    }
    for (var expense in monthlyexpenses) {
      double amount = double.tryParse(expense['monthlyamount']!.text) ?? 0.0;
      totalspentBudget += amount;
    }
    totalspentbudget2 = totalspentBudget + totalspentBudget;
    //double remainingBudget = double.parse(widget.budget) - totalspentBudget;
    //String remainingBudgetString = remainingBudget.toStringAsFixed(2);
  }

  void _addmonthcategoryField() {
    setState(() {
      monthlyexpenses.add({
        'date': TextEditingController(
            text: _formatDate(
                DateTime.now())), // Add TextEditingController for date
        'monthcategory': TextEditingController(),
        'monthlyamount': TextEditingController(),
        'remarks': TextEditingController(),
      });
      updatetotalspent();
    });
  }



  Future<void> _getTotalIncomeForSelectedMonth() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedMonth = DateFormat.M().format(_selectedDate);
    String? totalIncomeForSelectedMonth = prefs.getStringList('totalIncomes')?.fold('0', (previousValue, incomeId) {
      String? month = prefs.getString('$incomeId:selectedMonth');
      if (month == selectedMonth) {
        String? income = prefs.getString('$incomeId:totalincome');
        if (income != null) {
          return (double.parse(previousValue!) + double.parse(income)).toString();
        }
      }
      return previousValue;
    });

    setState(() {
      // totalIncome = totalIncomeForSelectedMonth ?? '0';
    });
  }

  Future<void> _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> incomeIds = prefs.getStringList('incomeIds') ?? [];

    List<Map<String, dynamic>> loadedTrips = [];

    for (String incomeId in incomeIds) {
      List<String> monthlyExpenses =
          prefs.getStringList('${widget.incomeId}:monthlyexpenses') ?? [];
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

    setState(() {
      trips = loadedTrips;
    });
  }

  @override
  void initState() {
    super.initState();
    _addmonthcategoryField();
    updatetotalspent();
    _loadDataFromSharedPreferences();
    _getTotalIncomeForSelectedMonth();
    _loadDataForMonthly();
  }

  @override
  Widget build(BuildContext context) {

    //double Monthlyincome = double.tryParse(monthlyincome.text.toString());

    double totalBudgetAmount = _calculateTotalBudget(trips);
    double remainingOrDebit =
        (double.tryParse(monthlyincome.text.toString()) ?? 0.0) - totalBudgetAmount;

// Determine the text and style based on the calculated value
    String textToShow = remainingOrDebit >= 0 ? 'Remaining' : 'Debit';
    Color textColor = remainingOrDebit >= 0 ? Colors.black : Colors.orange;

    ///totalremaining
    double total = (totalAmountPerson - remainingOrDebit.abs()).abs();
    List<Widget> monthlyAmounts = [];
    for (var i = 0; i < trips.length; i++) {
      for (var j = 0; j < trips[i]['expenses'].length; j++) {
        monthlyAmounts.add(
          Text(
            'Amount : ₹ ${trips[i]['expenses'][j]['monthlyamount']}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }
    Map<String, double> aggregatedData = {};

    for (var i = 0; i < trips.length; i++) {
      for (var j = 0; j < trips[i]['expenses'].length; j++) {
        String category = trips[i]['expenses'][j]['monthcategory'];
        double amount = double.parse(trips[i]['expenses'][j]['monthlyamount'].toString());
        // Ensure that the aggregatedData map contains the category
        aggregatedData[category] = (aggregatedData[category] ?? 0) + amount;
      }
    }

    List<SalesData> chartData = [];
    aggregatedData.forEach((category, amount) {
      chartData.add(SalesData(category, amount));
    });
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Text(
            "Monthly Budget",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyDashboard(user_id: "9")));
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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              /*  Text(
                '${remainingOrDebit.abs()}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              Text(
                'Total: ₹${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),*/


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  TextButton(onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text("Add Your Credit", style: Theme.of(context).textTheme.bodyLarge),
                              insetPadding: EdgeInsets.zero,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                              shadowColor: Colors.deepPurple,
                              content: SizedBox(
                                height: 100,
                                width: 250,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 250,
                                      child: TextFormField(
                                        controller: incomeType,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Income Type',
                                          labelStyle: Theme.of(context).textTheme.bodySmall,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          /* border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),*/
                                        ),
                                      ),
                                    ), ///Income Type
                                    SizedBox(height: 15),
                                    SizedBox(
                                      height: 40,
                                      width: 250,
                                      child: TextFormField(
                                        controller: income,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Income Amount',
                                          labelStyle: Theme.of(context).textTheme.bodySmall,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          /*border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),*/
                                        ),
                                      ),
                                    ), /// Income Amount

                                  ],
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    _saveDataToSharedPreferencesCredit();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  MonthlyBudget2(
                                        incomeId: widget.incomeId,
                                      )),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal), // Set your desired color here
                                  ),

                                  child: Text("Ok",style: TextStyle(color: Colors.white),),
                                ),
                              ],
                              backgroundColor: Colors.teal.shade50,

                            );
                          },
                        );
                      },
                    );
                  },
                    child: Text(""
                        "Add Your Income+"),),


                  RichText(
                    text: TextSpan(
                      children: [

                        TextSpan(
                          text: '${fromDate.text} / ${toDate.text}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),





                ],

              ),  ///  Text Field


              SizedBox(height: 10,),

              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Set border radius to 20
                ),
                child: Column(
                  children: [

                    /// receivedamnt

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(SimpleIcons.bitcomet, color: Colors.white),
                            backgroundColor: Colors.blue, // Set the background color of the circle avatar
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start, // Align the text widgets in the center
                              children: [
                                Text('Income',style: Theme.of(context).textTheme.labelMedium),
                                SizedBox(width: 70,),
                                Text('₹${double.parse(monthlyincome.text).toStringAsFixed(2)}' ,style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: 2), // Add space between the row and the text widgets
                            Container(
                              width: 200, // Set the desired width
                              child: LinearProgressIndicator(
                                value: monthlyincome != 0 ? 1.0 : 0.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          ],
                        ),// Adjust the space between the icon and progress bar
                      ],
                    ),   ///Income
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(SimpleIcons.affine, color: Colors.white),
                            backgroundColor: totalBudgetAmount > double.parse(monthlyincome.text)
                                ? Colors.red // Orange color when spent exceeds received amount
                                : Colors.teal,                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Budget', style: Theme.of(context).textTheme.labelMedium),
                                SizedBox(width: 70),
                                Text('₹${totalBudgetAmount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.labelMedium),
                              ],
                            ),
                            SizedBox(height: 2), // Add space between the row and the text widgets
                            Container(
                              width: 200, // Set the desired width
                              child: LinearProgressIndicator(
                                value: totalBudgetAmount = totalBudgetAmount / double.parse(monthlyincome.text),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  totalBudgetAmount > double.parse(monthlyincome.text)
                                      ? Colors.teal // Orange color when spent exceeds received amount
                                      : Colors.red, // Red color for debit
                                ),
                              ),
                            )
                          ],
                        ),// Adjust the space between the icon and progress bar
                      ],
                    ),///Budget///
                    /* Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${remainingOrDebit.abs()}',
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      ],
                    ), *//// Reamining



                  ],
                ),
              ),

              SizedBox(height: 10,),


              Container(
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,

                ),
                child: ExpansionTile(
                  title: Text('Chart',
                    style: TextStyle(
                      fontSize: 18, // Increase font size for the title
                      fontWeight: FontWeight.bold, // Add bold font weight
                      //   color: Colors.blue, // Change text color
                    ),),
                  backgroundColor: Colors.white70,// Title of the ExpansionTile
                  children: [
                    Container(
                      height: 200,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // Set border radius to 20
                      ),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: double.tryParse(monthlyincome.text.toString()),
                          interval: (double.tryParse(monthlyincome.text.toString()) ?? 0.0) / 4,
                          numberFormat: NumberFormat.compact(),
                        ),
                        series: <CartesianSeries>[
                          BarSeries<SalesData, String>(
                            dataSource: chartData,
                            xValueMapper: (SalesData sales, _) => sales.category,
                            yValueMapper: (SalesData sales, _) => sales.amount,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.inside, // Adjust label position
                            ),
                            // Assigning colors directly to each data point
                            pointColorMapper: (SalesData sales, _) => _getColorForCategory(sales.category),
                            width: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), /// Chart


              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              errormsg ??
                                  "", // Display the error message if it's not null
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),  /// Error message
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                              boxShadow: [],
                              gradient: const LinearGradient(
                                // Gradient background
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white70, Colors.white70],
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 0; i < monthlyexpenses.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: monthlyexpenses[i][
                                              'date']!, // Assuming expense['date'] is already a TextEditingController
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                              onTap: () async {
                                                // Show date picker when the field is tapped
                                                DateTime? pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                  builder: (BuildContext context,
                                                      Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        colorScheme:
                                                        ColorScheme.light(
                                                          primary:
                                                          Color(0xFF8155BA),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    monthlyexpenses[i]['date']!.text =
                                                        _formatDate(pickedDate);
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                            TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: monthlyexpenses[i]['monthcategory']!,
                                                onChanged: (value) {
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: monthlyexpenses[i]['monthcategory']!.text.isEmpty
                                                      ? 'Categories'
                                                      : null,
                                                  hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
                                                ),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              suggestionsCallback: (pattern) {
                                                // List of suggestions
                                                List<String> suggestions = [
                                                  // Headings
                                                  'Daily Expenses',
                                                  'Housing',
                                                  'Transportation',
                                                  'Food',
                                                  'Debt Payments',
                                                  'Insurance',
                                                  'Savings',
                                                  'Personal Expenses',
                                                  'Utilities',
                                                  'Healthcare',
                                                  'Education',
                                                  'Charity/Donations',
                                                  'Miscellaneous',
                                                  // Categories
                                                  'Rent/Mortgage',
                                                  'Utilities',
                                                  'Groceries',
                                                  'Credit Card Payments',
                                                  'Health Insurance',
                                                  'Emergency Fund',
                                                  'Clothing',
                                                  'Electricity',
                                                  'Doctor Visits',
                                                  'Tuition',
                                                  'Regular Donations',
                                                  'Other Expenses',
                                                ];
                                                return suggestions;
                                              },
                                              itemBuilder: (context, String suggestion) {
                                                if (
                                                suggestion == 'Daily Expenses' ||
                                                    suggestion == 'Housing' ||
                                                    suggestion == 'Transportation' ||
                                                    suggestion == 'Food' ||
                                                    suggestion == 'Debt Payments' ||
                                                    suggestion == 'Insurance' ||
                                                    suggestion == 'Savings' ||
                                                    suggestion == 'Personal Expenses' ||
                                                    suggestion == 'Utilities' ||
                                                    suggestion == 'Healthcare' ||
                                                    suggestion == 'Education' ||
                                                    suggestion == 'Charity/Donations' ||
                                                    suggestion == 'Miscellaneous') {
                                                  // If it's a heading, display it differently
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  );
                                                } else {
                                                  // If it's a category, display it normally
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  );
                                                }
                                              },
                                              onSuggestionSelected: (String suggestion) {
                                                monthlyexpenses[i]['monthcategory']!.text = suggestion;
                                                monthlyexpenses[i]['monthcategory']!.selection =
                                                    TextSelection.collapsed(offset: suggestion.length);
                                                monthlyexpenses[i]['monthcategory']!.value = TextEditingValue(
                                                  text: suggestion,
                                                  selection: TextSelection.collapsed(offset: suggestion.length),
                                                );
                                              },
                                            ),
                                          ),

                                          /// Cargories

                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: monthlyexpenses[i]
                                              ['monthlyamount'],
                                              style: const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                setState(() {
                                                  //updatetotalspent();
                                                  _updateTotalBudget2();
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: monthlyexpenses[i]
                                                ['monthlyamount']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Rs'
                                                    : null,
                                                hintStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),

                                          /// Amount
                                          IconButton(
                                            icon: const Icon(Icons.note_alt_sharp,
                                                color: Colors.green),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Notes",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors
                                                              .blue), // Change text size and color
                                                    ),
                                                    content: Container(
                                                      width: double.maxFinite,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "Category: ${monthlyexpenses[i]['monthcategory']!.text}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          Text(
                                                            "Amount: ${monthlyexpenses[i]['monthlyamount']!.text}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          TextField(
                                                            controller:
                                                            monthlyexpenses[i]
                                                            ['remarks'],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black), // Change input text size and color
                                                            decoration:
                                                            InputDecoration(
                                                              labelText: "Add",
                                                              labelStyle: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blue), // Change label text size and color
                                                            ),
                                                          ),
                                                          if (notesList.isNotEmpty)
                                                            Container(
                                                              height: 100,
                                                              child:
                                                              ListView.builder(
                                                                itemCount: notesList
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                    index) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                      notesList[
                                                                      index],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          14,
                                                                          color: Colors
                                                                              .black), // Change list item text size and color
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .red), // Change button text size and color
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            ///  String category = monthlyexpenses[i]['monthcategory']!.text;
                                                            ///  String amount = monthlyexpenses[i]['monthlyamount']!.text;
                                                          });
                                                        },
                                                        child: Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .green), // Change button text size and color
                                                        ),
                                                      ),
                                                    ],
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Color(
                                                              0xFF8155BA)), // Set border color here
                                                      borderRadius:
                                                      BorderRadius.zero,

                                                      // Remove border radius
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),

                                          ///remarks

                                          IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors
                                                    .red), // You can change the icon here
                                            onPressed: () {
                                              setState(() {
                                                monthlyexpenses.removeAt(i);
                                                //updatetotalspent(); // _updateTotalBudget();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ), /// date catgories amount
                      ],
                    ), /// date catgories amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Add .00 to the entered amount for each expense
                              for (var i = 0; i < monthlyexpenses.length; i++) {
                                var currentAmount =
                                    monthlyexpenses[i]['monthlyamount']!.text;
                                if (!currentAmount.contains('.')) {
                                  monthlyexpenses[i]['monthlyamount']!.text =
                                  '$currentAmount.00';
                                }
                              }
                            });
                            _addmonthcategoryField();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8155BA)
                                .withOpacity(0.8), // Change button color here
                            elevation: 5, // Add elevation
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              List<String?> errorMessages = List.filled(
                                  monthlyexpenses.length,
                                  ''); // List to store error messages for each row
                              bool isValid =
                              true; // Flag to track overall form validity
                              for (var i = 0; i < monthlyexpenses.length; i++) {
                                if (monthlyexpenses[i]['monthcategory']!
                                    .text
                                    .isEmpty) {
                                  errorMessages[i] = "* Enter a Category Name";
                                  isValid =
                                  false; // Set flag to false if any row has an error
                                } else if (monthlyexpenses[i]['monthlyamount']!
                                    .text
                                    .isEmpty) {
                                  errorMessages[i] = "* Enter an Amount";
                                  isValid =
                                  false; // Set flag to false if any row has an error
                                } else {
                                  // No error for this row
                                  errorMessages[i] = null;
                                }
                              }
                              // Check overall form validity
                              if (isValid) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Saved Succesfully'),
                                      content: Text(
                                          ''),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> MonthlyBudget2(
                                              incomeId: widget.incomeId,
                                              // totalIncome: widget.totalIncome,
                                              // incomeType: widget.incomeType,
                                              // selectedFromDate: widget.selectedFromDate,
                                              // selectedToDate: widget.selectedToDate,

                                            )));
                                            _saveDataToSharedPreferences(remainingOrDebit);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green
                                                .withOpacity(
                                                0.8), // Change button color here
                                            elevation: 5, // Add elevation
                                          ),
                                          child: Text('OK',
                                              style:
                                              TextStyle(color: Colors.black)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              else {
                                // Set error messages for each row
                                StringBuffer errorMessageBuffer =
                                StringBuffer(); // Use StringBuffer to concatenate error messages
                                for (var i = 0; i < monthlyexpenses.length; i++) {
                                  if (errorMessages[i] != null) {
                                    errorMessageBuffer.writeln(errorMessages[
                                    i]); // Append error message for each row
                                  }
                                }
                                setState(() {
                                  errormsg = errorMessageBuffer
                                      .toString(); // Set error message
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8155BA)
                                  .withOpacity(0.8), // Change button color here
                              elevation: 5, // Add elevation
                            ),
                            child: Text('SAVE',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    for (var i = 0; i < trips.length; i++)
                      for (var j = 0; j < trips[i]['expenses'].length; j++)
                        Container(
                          width: 350,
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Color(0xFF8155BA),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          alignment: (i + j) % 2 == 0
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Category: ${trips[i]['expenses'][j]['monthcategory']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${trips[i]['expenses'][j]['date']}',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Text(
                                    'Amount  : ₹ ${trips[i]['expenses'][j]['monthlyamount']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_forever, color: Colors.red),
                                    onPressed: () {
                                      _deleteExpense(i, j);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              if (trips[i]['expenses'][j]['remarks'].isNotEmpty)
                                Text(
                                  'Remarks :  ${trips[i]['expenses'][j]['remarks']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                    // Display the total spent amount after iterating through all expenses
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Fuel':
        return Colors.blue;
      case 'Tollgate':
        return Colors.pink;
      case 'Tickets':
        return Colors.purple;
      case 'Others':
        return Colors.black;
      default:
      // You can assign default colors for unknown categories here
      // For example, you can cycle through a list of predefined colors
      // Here, I'm using a simple approach by returning a different default color for each unknown category
        List<Color> defaultColors = [Colors.orange, Colors.teal, Colors.deepOrange, Colors.indigo];
        return defaultColors[category.hashCode % defaultColors.length]; // Default color for unknown categories
    }
  }

}
