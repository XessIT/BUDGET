import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Pie_chart.dart';
import 'expense_model.dart'; // Import your expense_model.dart file here

//part 'monthlyBudget.g.dart';

class MonthlyBudget extends StatefulWidget {
  const MonthlyBudget({Key? key}) : super(key: key);

  @override
  State<MonthlyBudget> createState() => _MonthlyBudgetState();
}

class _MonthlyBudgetState extends State<MonthlyBudget> {
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

  late Future<Box<Expense>> _boxFuture;
  late Box<BudgetInfo> budgetBox; // Box to store budget information
  //late Box<Expense>? expenseBox; // Make expenseBox nullable
  List<Map<String, TextEditingController>> expenses = [];
  List<Map<String, String>> submittedItems = []; // List to hold submitted items
  double totalSpendAmount = 0.0;
  double enteredAmount = 0.0; // Added to store entered budget amount
  double remainingAmount = 0.0;
  final TextEditingController _budgetController = TextEditingController();
  bool _showBudgetAlert = false;

  bool _isAddingCategory = false; // Track whether the user is adding a category
  bool istextfield = false;

  void _addCategoryField() {
    setState(() {
      _isAddingCategory = true; // Set the flag to true to show the container
      expenses.add({
        'category': TextEditingController(text: null),
        'amount': TextEditingController(),
        'date': TextEditingController(
            text: _formatDate(
                DateTime.now())), // Add TextEditingController for date
      });
    });
  }

  void _submit() async {
    final expenseBox = await _boxFuture; // Wait for the box to open
    // Initialize total spent amount
    setState(() {
      for (var expense in expenses) {
        expenseBox?.add(Expense(
          date: expense['date']!.text ?? '',
          category: expense['category']!.text ?? '',
          amount: expense['amount']!.text ?? '',
        ));
        // Add the amount to the total spend
        totalSpendAmount += double.tryParse(expense['amount']!.text) ?? 0.0;
      }
      // Update totalSpendAmount
      //totalSpendAmount = totalSpend;
      // Update remaining amount
      remainingAmount = enteredAmount - totalSpendAmount;
      // Set the budget alert flag
      _showBudgetAlert = totalSpendAmount >= enteredAmount * 0.8;
      // Clear the expenses list
      expenses.clear();
      // Add new category field
      _addCategoryField();
    });
    // Trigger a rebuild of the widget tree to reflect the updated spent amount
    setState(() {});
  }

  ///fetch Data

  ///insert code


  void _initializeBudgetBox() async {
    await _openBudgetBox(); // Wait for the box to open
    //_calculateTotalAmount(); // Calculate total spend amount after initializing expenses
  }


  Future<void> _openBudgetBox() async {
    budgetBox = await Hive.openBox<BudgetInfo>('budget_info');
    // Load budget information if available
    final budgetInfo = budgetBox.get('budget',
        defaultValue: BudgetInfo(
          totalSpendAmount: 0.0,
          totalAmount: 0.0,
          remainingAmount: 0.0,
        ));
    if (budgetInfo != null) {
      setState(() {
        totalSpendAmount = budgetInfo.totalSpendAmount;
        enteredAmount = budgetInfo.totalAmount;
        remainingAmount = budgetInfo.remainingAmount;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _addCategoryField(); // Add initial category and amount fields
    _boxFuture = Hive.openBox<Expense>('expenses');
    _openBudgetBox();
    _initializeBudgetBox();
  }

  void _saveBudgetInfo() {
    budgetBox.put(
        'budget',
        BudgetInfo(
          totalSpendAmount: totalSpendAmount,
          totalAmount: enteredAmount,
          remainingAmount: remainingAmount,
        ));
  }

  @override
  void dispose() {
    _saveBudgetInfo(); // Save budget information before disposing the widget
    super.dispose();
  }

  void _showSetAmountDialog() async {
   // SharedPreferences prefs = await SharedPreferences.getInstance();
    double? newAmount = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        double? enteredAmount;
        return AlertDialog(
          title: Text('Set Total Amount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    enteredAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
               // await prefs.setDouble('enteredAmount', enteredAmount ?? 0.0);
                Navigator.of(context).pop(enteredAmount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF006400),
                elevation: 5,
              ),
              child: Text(
                'Set',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      setState(() {
        enteredAmount = newAmount;
      });
    }
  }

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






  @override
  Widget build(BuildContext context) {

    double remainingBudget = enteredAmount - totalSpendAmount;
    List<List<Color>> gradientList = [];
    List<Color> colorList = [];

    if (remainingBudget > 0) {
      // If there is remaining budget, show green color for full circle
      gradientList = [
        [
          Color.fromRGBO(223, 250, 92, 1),
          Color.fromRGBO(129, 250, 112, 1),
        ]
      ];
      colorList = [Colors.greenAccent];
    } else {
      // If budget is fully spent or exceeded, show red color for full circle
      gradientList = [
        [
          Color.fromRGBO(175, 63, 62, 1.0),
          Color.fromRGBO(254, 154, 92, 1),
        ]
      ];
      colorList = [Colors.red];
    }
    Map<String, double> dataMap = {
      'Total Budget': enteredAmount,
      'Total Spent': totalSpendAmount,

    };



    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Budget",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFF8155BA), // Make the app bar transparent
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.history,
                color: Colors.black,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _showSetAmountDialog();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 30,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [Color(0xFF8155BA), Color(0xFFCA436B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TyperAnimatedTextKit(
                          onTap: () {
                            _showSetAmountDialog();
                          },
                          isRepeatingAnimation: true,
                          speed: Duration(milliseconds: 100),
                          text: ['Set Your Budget Here'],
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),  /// set your budget

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: Duration(milliseconds: 800),
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 3.2,
                      gradientList: gradientList,
                      colorList: colorList,
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
                ),
              ),
            ),       /// Pie chart

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 7, // Blur radius
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                    gradient: LinearGradient(
                      // Gradient background
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8155BA), // Your AppBar color
                        Color(0xFF9D7ED9),
                      ],
                    ),
                  ),

                  ///
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<Map<String, double>>(
                      future: _getBudgetDetails(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, double>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          double enteredAmount =
                              snapshot.data!['enteredAmount'] ?? 0.0;
                          double totalSpendAmount =
                              snapshot.data!['totalSpendAmount'] ?? 0.0;
                          double remainingAmount =
                              snapshot.data!['remainingAmount'] ?? 0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget: $enteredAmount',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),   /// Budget
                              SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: enteredAmount != 0
                                    ? totalSpendAmount / enteredAmount
                                    : 0,
                                backgroundColor: Colors.white.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  totalSpendAmount <= enteredAmount * 0.8
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Total Spent: \$${totalSpendAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),   /// Spent
                              SizedBox(height: 8),
                              Text(
                                'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),  /// Remaining Budget
                              SizedBox(height: 8),
                              if (_showBudgetAlert)
                                Text(
                                  'You have spent more than 80% of your budget.',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                  )),
            ),   /// Budget spent remaing fields
            SizedBox(
              height: 10,
            ), /// Sized

            Container(
              // color: Colors.grey.shade200,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.5), // Shadow color
                                spreadRadius: 5, // Spread radius
                                blurRadius: 7, // Blur radius
                                offset:
                                Offset(0, 3), // Changes position of shadow
                              ),
                            ],
                            gradient: LinearGradient(
                              // Gradient background
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF8155BA), // Your AppBar color
                                Color(0xFF9D7ED9),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              for (var expense in expenses)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 8, right: 8, bottom: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: expense[
                                          'date'], // Assuming expense['date'] is already a TextEditingController
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
                                                      Colors.blueAccent,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickedDate != null) {
                                              setState(() {
                                                expense['date']?.text =
                                                    _formatDate(pickedDate);
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            // labelText: 'Date',
                                            // labelStyle: TextStyle(fontSize: 18, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: null, // Default value is null
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              expense['category']!.text =
                                                  newValue ?? '';
                                            });
                                          },
                                          items: <String>[
                                            'Food',
                                            'Gas',
                                            'Rent',
                                            'Others'
                                          ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                          decoration: InputDecoration(
                                            hintText: 'Category',
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: expense['amount'],
                                          style: TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Amount',
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _addCategoryField();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006400), // Change button color here
                          elevation: 5, // Add elevation
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Submit Confirmation'),
                                  content:
                                  Text('Are you sure you want to submit?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _submit(); // Call _submit() function when the user confirms
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green, // Change button color here
                                        elevation: 5, // Add elevation
                                      ),
                                      child: Text('Submit',
                                          style:
                                          TextStyle(color: Colors.white)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Change button color here
                                        elevation: 5, // Add elevation
                                      ),
                                      child: Text('Cancel',
                                          style:
                                          TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF006400), // Change button color here
                            elevation: 5, // Add elevation
                          ),
                          child: Text('Submit',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ), /// catgories filed
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Expenses",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                //color: Colors.grey.shade200, // Light background color
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                ],
              ),
              child: FutureBuilder<Box<Expense>>(
                future: _boxFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final expenseBox = snapshot.data!;
                    return StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 1,
                      itemCount: expenseBox.length,
                      itemBuilder: (BuildContext context, int index) {
                        final expense = expenseBox.getAt(index)!;
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category: ${expense.category ?? ''}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Amount: ${expense.amount ?? ''}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Date: ${expense.date ?? ''}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    );
                  }
                },
              ),
            ), /// expaneses field

          ],
        ),
      ),
    );
  }
}

Future<Map<String, double>> _getBudgetDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double enteredAmount = prefs.getDouble('enteredAmount') ?? 0.0;

  // Open the Hive box where expenses are stored
  final expenseBox = await Hive.openBox<Expense>('expenses');

  // Calculate total spend amount by iterating over expenses
  double totalSpendAmount = 0.0;
  for (var i = 0; i < expenseBox.length; i++) {
    Expense expense = expenseBox.getAt(i)!;
    totalSpendAmount += double.tryParse(expense.amount) ?? 0.0;
  }

  double remainingAmount = enteredAmount - totalSpendAmount;

  return {
    'enteredAmount': enteredAmount,
    'totalSpendAmount': totalSpendAmount,
    'remainingAmount': remainingAmount,
  };
}
