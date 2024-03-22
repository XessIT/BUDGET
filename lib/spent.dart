import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';


import 'TripView.dart';

class SpentDetails extends StatefulWidget {

  final String budget;
  final String tripId;
  final String tripid;
  final String members;
  final String receivedamnt;
  final List<Map<String, String>> expenses;
  final List<Map<String, String>> expenses2;

  SpentDetails({super.key,
    required this.budget,
    required this.tripid,
    required this.tripId,
    required this.members,
    required this.expenses,
    required this.expenses2,
    required this.receivedamnt,
  });

  @override
  State<SpentDetails> createState() => _SpentDetailsState();
}

class _SpentDetailsState extends State<SpentDetails> {
  List<Map<String, dynamic>> trips = [];
  List<Map<String, TextEditingController>> spentexpenses = [];
  List<Map<String, String>> submittedItems = []; // List to hold submitted items
  double totalBudget = 0.0; // Track whether the user is adding a spentcategory
  bool istextfield = false;
  List<String> notesList = [];
  String? errormsg = '';
  TextEditingController _noteController = TextEditingController();



  void _loadDataFromSharedPreferences(String tripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> tempTrips = [];

    String expensesKey = '$tripId:spentexpenses';
    List<String>? expensesList = prefs.getStringList(expensesKey);
    List<Map<String, String>> spentexpenses = [];

    if (expensesList != null) {
      spentexpenses = expensesList.map((spentexpense) {
        List<String> parts = spentexpense.split(':');
        return {
          'spentcategory': parts[0],
          'spentamount': parts[1],
          'date': parts[2], // Add date field here
          'remarks': parts[3],
        };
      }).toList();
    }

    // Load 'notesList' from SharedPreferences
    List<String>? savedNotes = prefs.getStringList('$tripId:notes') ?? [];
    double totalSpent = prefs.getDouble('$tripId:totalSpent') ?? 0.0;
    double remaining = prefs.getDouble('$tripId:remaining') ?? 0.0;
    double debit = prefs.getDouble('$tripId:debit') ?? 0.0;
    // Replace 'totalBudget' with the actual variable that holds the total budget
    tempTrips.add({
      'totalBudget': totalBudget.toString(), // Replace with the actual variable
      'expenses': spentexpenses,
      'notesList': savedNotes,
      'totalSpent': totalSpent,
      'remaining': remaining,
      'debit': debit,
    });

    // Ensure 'trips' is initialized before setting the state
    setState(() {
      trips = tempTrips;
    });
  }

  List<Widget> expenseWidgets = [];

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

  double calculateTotalSpentAmount(List trips) {
    double totalSpentAmount = 0.0;
    for (var trip in trips) {
      for (var expense in trip['expenses']) {
        // Convert the string to double before adding to totalSpentAmount
        totalSpentAmount += double.parse(expense['spentamount']);
      }
    }
    return totalSpentAmount;
  }

  void _saveDataToSharedPreferences(String remainingBudgetString, String debitBudgetString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tripId = widget.tripid;

    // Retrieve existing data
    List<String> tripIds = prefs.getStringList('tripIds') ?? [];
    Map<String, double> expensesMap = Map<String, double>.from(
        prefs.getStringList('$tripId:spentexpenses')?.fold({}, (prev, element) {
          var parts = element.split(':');
          prev?[parts[0]] = double.parse(parts[1]);
          return prev;
        }) ??
            {});

    // Retrieve existing notes
    List<String>? savedNotes = prefs.getStringList('$tripId:notes') ?? [];

    // Update or add new data
    prefs.setString('$tripId:totalBudget', totalBudget.toString());

    List<Map<String, String>> formattedExpenses = spentexpenses.map((expense) {
      return {
        'spentcategory': expense['spentcategory']!.text,
        'spentamount': expense['spentamount']!.text,
        'date': expense['date']!.text,
        'remarks': expense['remarks']!.text
      };
    }).toList();

    List<String> existingExpenses =
        prefs.getStringList('$tripId:spentexpenses') ?? [];
    existingExpenses.addAll(formattedExpenses.map((e) =>
    "${e['spentcategory']}:${e['spentamount']}:${e['date']}:${e['remarks']}"));

    prefs.setStringList('$tripId:spentexpenses', existingExpenses);

    // Save notes
    if (notesList.isNotEmpty) {
      savedNotes.addAll(notesList);
      prefs.setStringList('$tripId:notes', savedNotes);
    }

    if (!tripIds.contains(tripId)) {
      tripIds.add(tripId);
      prefs.setStringList('tripIds', tripIds);
    }
    prefs.setDouble('$tripId:totalSpent',
        double.parse(totalspentBudget.toStringAsFixed(2)));
    prefs.setDouble('$tripId:remaining', double.parse(remainingBudgetString));
    prefs.setDouble('$tripId:debit', double.parse(debitBudgetString));
    print("notesList$notesList");
    print('Income ID: $tripIds');
  }

  double totalspentbudget2 = 0.0;
  double totalspentBudget = 0.0;

  void updatetotalspent() {
    totalspentBudget = 0.0;
    double totalSpentAmount = 0.0;
    for (var trip in trips) {
      for (var expense in trip['expenses']) {
        // Convert the string to double before adding to totalSpentAmount
        totalspentBudget += double.parse(expense['spentamount']);
      }
    }



    for (var expense in spentexpenses) {
      double amount = double.tryParse(expense['spentamount']!.text) ?? 0.0;
      totalspentBudget += amount;
    }
    totalspentbudget2 = totalspentBudget + totalspentBudget;
    double remainingBudget = double.parse(widget.budget) - totalspentBudget;
    String remainingBudgetString = remainingBudget.toStringAsFixed(2);
  }

  Widget RowText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget StyledText(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// Custom Text widget with styling for spentamount values
  Widget StyledspentamountText(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addspentcategoryField() {
    setState(() {
      spentexpenses.add({
        'date': TextEditingController(
            text: _formatDate(
                DateTime.now())), // Add TextEditingController for date
        'spentcategory': TextEditingController(),
        'spentamount': TextEditingController(),
        'remarks': TextEditingController(),
      });
      updatetotalspent();
    });
  }

  String spentBudgetText = "0.0"; // Initialize with a default value

  void _updateTotalBudget() {
    double spentBudget = 0.0;
    for (var trip in trips) {
      for (var expense in trip['expenses']) {
        var spentamount = double.tryParse('${expense['spentamount']}') ?? 0.0;
        spentBudget += spentamount;
        print(spentamount); // Accumulate the spentamount for spent budget
      }
    }
    // Update the text widget for "Spent Budget"
    spentBudgetText = spentBudget.toString(); // Convert to string
    // Update the total budget after calculating spentBudget
    totalBudget = double.tryParse('${widget.budget}') ?? 0.0;
  }

  void _removespentcategoryField(int index) {
    setState(() {
      spentexpenses.removeAt(index);
      //_updateTotalBudget();
    });
  }

  TextEditingController spentCategoryController = TextEditingController();
  TextEditingController spentAmountController = TextEditingController();
  double totalSpentAmount = 0.0;

  ///debit calculation
  double calculateDebit(String budget, List<Map<String, dynamic>> trips) {
    double totalBudget = double.parse(budget);
    double totalSpentAmount = calculateTotalSpentAmount(trips);

    if (totalBudget < totalSpentAmount) {
      // Calculate debit only if Total Budget is less than Total Spent Amount
      return totalSpentAmount - totalBudget;
    } else {
      return 0.0; // No debit if Total Budget is greater than or equal to Total Spent Amount
    }
  }

  void _deleteExpense(int tripIndex, int expenseIndex) {
    setState(() {
      trips[tripIndex]['expenses'].removeAt(expenseIndex);
    });
    _updateBackendData();
  }  /// This for Delete coding

  void _updateBackendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tripId = widget.tripid;

    // Convert the updated expenses list to a format suitable for SharedPreferences
    List<String> updatedExpenses = trips
        .map<List<String>>((trip) => trip['expenses']
        .map<String>((expense) =>
    "${expense['spentcategory']}:${expense['spentamount']}:${expense['date']}:${expense['remarks']}")
        .toList())
        .expand<String>((x) => x)
        .toList();

    // Update the expenses data in SharedPreferences
    prefs.setStringList('$tripId:spentexpenses', updatedExpenses);
  }  /// this for after delete using Update coding

  List<Map<String, TextEditingController>> expenses2 = [];

  void _loadDataForTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String personsKey = '${widget.tripid}:persons';

    setState(() {
      List<String>? personsList = prefs.getStringList(personsKey);
      expenses2 = personsList!.map((person) {
        List<String> parts = person.split(':');
        print(expenses2);

        return {
          'name': TextEditingController(text: parts[0]),
          'perAmount': TextEditingController(text: parts[1]),
        };
      }).toList() ;
    });
  }

  int index = 0;
  @override
  void initState() {
    super.initState();
    print(widget.members);
    _loadDataFromSharedPreferences(widget.tripid);
    _addspentcategoryField();
    updatetotalspent();
    _updateTotalBudget();
    _loadDataForTrip();
  }

  @override
  Widget build(BuildContext context) {
    double receivedAmount = double.parse(widget.receivedamnt);

    double remainingBudget =
        double.parse(widget.receivedamnt) - totalspentBudget;

// Ensure remainingBudget is not negative
    remainingBudget = remainingBudget.clamp(0.0, double.infinity);

    String remainingBudgetString = remainingBudget.toStringAsFixed(2);

// Check if Total Budget < Total Spent Budget
    bool isTotalBudgetLess =
        double.parse(widget.receivedamnt) < totalspentBudget;

    double debitBudget = isTotalBudgetLess
        ? totalspentBudget - double.parse(widget.receivedamnt)
        : 0.0;

    double members = double.parse(widget.members);

// Calculate results with a fallback value of 0.0 in case members is zero
    double results = members != 0.0 ? remainingBudget / members : 0.0;

    String formattedResults = results.toStringAsFixed(2);

    String debitBudgetString = debitBudget.toStringAsFixed(2);

    double debitresults = members != 0.0 ? debitBudget / members : 0.0;
    // String debitBudgetString = debitBudget.toStringAsFixed(2);

    // Define a map to store aggregated spending amounts based on categories
    // Define a map to store aggregated spending amounts based on categories
    Map<String, double> aggregatedData = {};

    for (var i = 0; i < trips.length; i++) {
      for (var j = 0; j < trips[i]['expenses'].length; j++) {
        String category = trips[i]['expenses'][j]['spentcategory'];
        double amount = double.parse(trips[i]['expenses'][j]['spentamount']);
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
      appBar: AppBar(
        title: Text(
          "Spent ",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: (double.parse(widget.receivedamnt) -
                  calculateTotalSpentAmount(trips)) >=
                  0,
              child: GestureDetector(
                onTap: () {
                  // Calculate remaining budget per member
                  double remainingBudgetPerMember =
                      (double.parse(widget.receivedamnt) -
                          calculateTotalSpentAmount(trips)) /
                          int.parse(widget.members);

                  // Show alert box here
                  // Show alert box here
                  // Show alert box here
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      double totalReceivedAmount = double.parse(widget.receivedamnt);
                      double totalSpentAmount = calculateTotalSpentAmount(trips);
                      double remainingAmount = totalReceivedAmount - totalSpentAmount;
                      int numberOfMembers = int.parse(widget.members);
                      double perPersonSpend = totalSpentAmount / numberOfMembers;
                      double perPersonRemaining = remainingAmount / numberOfMembers;

                      // Get the list of members and their received amounts
                      List<Map<String, dynamic>> membersData = List<Map<String, dynamic>>.from(widget.expenses2);

                      // Calculate the return amount for each member
                      List<Map<String, dynamic>> returnAmounts = [];
                      double totalReturnAmount = 0;
                      for (var memberData in membersData) {
                        double receivedAmount = double.tryParse(memberData['perAmount']) ?? 0;
                        double returnAmount = perPersonSpend - receivedAmount;
                        returnAmounts.add({
                          'name': memberData['name'],
                          'receivedAmount': receivedAmount,
                          'returnAmount': returnAmount,
                        });
                        totalReturnAmount += returnAmount;
                      }

                      return AlertDialog(
                        title: Text("Remaining Details"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.deepPurple),
                        ),
                        content: Container(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Received: ₹${totalReceivedAmount.toStringAsFixed(2)}'),
                                Text('Total Spent: ₹${totalSpentAmount.toStringAsFixed(2)}'),
                                Text('Spent per head: ₹${perPersonSpend.toStringAsFixed(2)}'),
                                Text('Remaining: ₹${remainingAmount.toStringAsFixed(2)}'),
                                Text("Members: $numberOfMembers"),
                                SizedBox(height: 10),
                                Table(
                                  border: TableBorder.all(),
                                  columnWidths:  {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Name'),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Received ₹'),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(remainingAmount == 0.00 ? 'Balance ₹' : 'Return ₹'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Generate rows based on return amounts
                                    for (var returnData in returnAmounts)
                                      TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('${++index}. ${returnData['name']}'), // Increment index and display in the format "1. Name"
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(returnData['receivedAmount'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                              Text(
                                                returnData['returnAmount'] < 0
                                                    ? returnData['returnAmount'].toStringAsFixed(2)
                                                    : '${returnData['returnAmount'].abs().toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: returnData['returnAmount'] < 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );


                },
                child: Icon(Icons.terrain_rounded, color: Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: double.parse(widget.receivedamnt) <
                calculateTotalSpentAmount(trips),
            child: SizedBox(
              width: 0,
            ), // Add space before DEBIT text
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: double.parse(widget.receivedamnt) < calculateTotalSpentAmount(trips),
              child: GestureDetector(
                onTap: () {
                  double totalReceivedAmount = double.parse(widget.receivedamnt);
                  double totalSpentAmount = calculateTotalSpentAmount(trips);
                  double debitAmount = totalSpentAmount - totalReceivedAmount;
                  int numberOfMembers = int.parse(widget.members);
                  double perPersonSpend = totalSpentAmount / numberOfMembers;

                  // Get the list of members and their received amounts
                  List<Map<String, dynamic>> membersData = List<Map<String, dynamic>>.from(widget.expenses2);

                  // Calculate the debit amount for each member
                  List<Map<String, dynamic>> debitAmounts = [];
                  /*
                  for (var memberData in membersData) {
                    double receivedAmount = double.tryParse(memberData['perAmount']) ?? 0;
                    double debitForThisMember = (perPersonSpend - receivedAmount) > 0 ? (perPersonSpend - receivedAmount) : 0;
                    debitAmounts.add({
                      'name': memberData['name'],
                      'receivedAmount': receivedAmount,
                      'debitAmount': debitForThisMember,
                    });
                  }
      */
                  for (var memberData in membersData) {
                    double receivedAmount = double.tryParse(memberData['perAmount']) ?? 0;
                    double debitForThisMember = perPersonSpend - receivedAmount;
                    debitAmounts.add({
                      'name': memberData['name'],
                      'receivedAmount': receivedAmount,
                      'debitAmount': debitForThisMember,
                    });
                  }

                  // Show alert box here
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Debit Details"),
                        content: Container(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Received: ₹${totalReceivedAmount.toStringAsFixed(2)}'),
                                Text('Total Spent: ₹${totalSpentAmount.toStringAsFixed(2)}'),
                                Text('Debit Amount: ₹${debitAmount.toStringAsFixed(2)}'),
                                Text('Spent per head: ₹${perPersonSpend.toStringAsFixed(2)}'),
                                Text("Members: ${widget.members}"),
                                SizedBox(height: 10),
                                Table(
                                  border: TableBorder.all(),
                                  columnWidths: {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Name'),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Received Amount'),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Debit Amount'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Generate rows based on debit amounts
                                    for (var debitData in debitAmounts)
                                      TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('${++index}. ${debitData['name']}'), // Increment index and display in the format "1. Name"
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(debitData['receivedAmount'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                              Text(
                                                debitData['debitAmount'] < 0
                                                    ? debitData['debitAmount'].toStringAsFixed(2)
                                                    : '${debitData['debitAmount'].abs().toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: debitData['debitAmount'] < 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.terrain_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TripDashboard()));
          },
        ),
        titleSpacing: 00.0,
        centerTitle: false,
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
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15,),
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
                                  SizedBox(width: 70,),
                                  Text('₹${double.parse(widget.budget).toStringAsFixed(2)}' ,style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2), // Add space between the row and the text widgets
                              Container(
                                width: 200, // Set the desired width
                                child: LinearProgressIndicator(
                                  value: totalBudget != 0 ? 1.0 : 0.0,
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
                              child: Icon(SimpleIcons.campaignmonitor, color: Colors.white),
                              backgroundColor: Colors.blue, // Set the background color of the circle avatar
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Received',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  SizedBox(width: 70),
                                  Text(
                                    '₹${double.parse(widget.receivedamnt).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Container(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: double.parse(widget.receivedamnt) / double.parse(widget.budget),
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),  /// Recevived
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(SimpleIcons.cashapp, color: Colors.white),
                              backgroundColor: calculateTotalSpentAmount(trips) > double.parse(widget.receivedamnt)
                                  ? Colors.pink // Orange color when spent exceeds received amount
                                  : Colors.red, // Red color for debit
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Spent',style: Theme.of(context).textTheme.labelMedium),
                                  SizedBox(width: 70,),
                                  Text(
                                    '₹${calculateTotalSpentAmount(trips).toStringAsFixed(2)}', style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Container(
                                width: 210,
                                child: LinearProgressIndicator(
                                  value: calculateTotalSpentAmount(trips) / double.parse(widget.receivedamnt),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    calculateTotalSpentAmount(trips) > double.parse(widget.receivedamnt)
                                        ? Colors.pink // Orange color when spent exceeds received amount
                                        : Colors.red, // Red color for debit
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ), /// Spent

                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(SimpleIcons.hearth, color: Colors.white),
                              backgroundColor: calculateTotalSpentAmount(trips) <= double.parse(widget.receivedamnt)
                                  ? Colors.green // Green color for remaining budget
                                  : Colors.red, // Red color for debit
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    calculateTotalSpentAmount(trips) <= double.parse(widget.receivedamnt)
                                        ? 'Remaining'
                                        : 'Debit',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  SizedBox(width: 70),
                                  Text(
                                    calculateTotalSpentAmount(trips) <= double.parse(widget.receivedamnt)
                                        ? '₹${(double.parse(widget.receivedamnt) - calculateTotalSpentAmount(trips)).toStringAsFixed(2)}'
                                        : '₹${(calculateTotalSpentAmount(trips) - double.parse(widget.receivedamnt)).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Container(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: calculateTotalSpentAmount(trips) <= double.parse(widget.receivedamnt)
                                      ? (double.parse(widget.receivedamnt) - calculateTotalSpentAmount(trips)) / double.parse(widget.receivedamnt)
                                      : (calculateTotalSpentAmount(trips) - double.parse(widget.receivedamnt)) / double.parse(widget.budget),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    calculateTotalSpentAmount(trips) <= double.parse(widget.receivedamnt)
                                        ? Colors.green // Green color for remaining budget
                                        : Colors.red, // Red color for debit
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),   /// Remaining

                      // Add other rows with CircleAvatar and LinearProgressIndicator here
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
                            maximum: receivedAmount,
                            interval: receivedAmount / 4,
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
                ),


                /// Chart
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
                              child: Column(
                                children: [
                                  for (var i = 0; i < spentexpenses.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: spentexpenses[i][
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
                                                    spentexpenses[i]['date']!.text =
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
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration:
                                              TextFieldConfiguration(
                                                controller: spentexpenses[i]
                                                ['spentcategory']!,
                                                onChanged: (value) {
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: spentexpenses[i]
                                                  ['spentcategory']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Categories'
                                                      : null,
                                                  hintStyle: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              suggestionsCallback: (pattern) {
                                                // List of suggestions
                                                List<String> suggestions = [
                                                  'Food',
                                                  'Fuel',
                                                  'Tollgate',
                                                  'Tickets',
                                                  'Others'
                                                ];

                                                return suggestions;
                                              },
                                              itemBuilder:
                                                  (context, String suggestion) {
                                                return ListTile(
                                                  title: Text(
                                                    suggestion,
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                );
                                              },
                                              onSuggestionSelected:
                                                  (String suggestion) {
                                                spentexpenses[i]['spentcategory']!
                                                    .text = suggestion;
                                                spentexpenses[i]['spentcategory']!
                                                    .selection =
                                                    TextSelection.collapsed(
                                                        offset: suggestion.length);
                                                spentexpenses[i]['spentcategory']!
                                                    .value = TextEditingValue(
                                                  text: suggestion,
                                                  selection:
                                                  TextSelection.collapsed(
                                                      offset:
                                                      suggestion.length),
                                                );
                                              },
                                            ),
                                          ),

                                          /// Cargories

                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: spentexpenses[i]
                                              ['spentamount'],
                                              style: const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                setState(() {
                                                  updatetotalspent();
                                                  //  _updateTotalBudget();
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: spentexpenses[i]
                                                ['spentamount']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Amount'
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
                                                            "Category: ${spentexpenses[i]['spentcategory']!.text}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          Text(
                                                            "Amount: ${spentexpenses[i]['spentamount']!.text}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          TextField(
                                                            controller:
                                                            spentexpenses[i]
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
                                                            ///  String category = spentexpenses[i]['spentcategory']!.text;
                                                            ///  String amount = spentexpenses[i]['spentamount']!.text;
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
                                                spentexpenses.removeAt(i);
                                                updatetotalspent(); // _updateTotalBudget();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
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
                                for (var i = 0; i < spentexpenses.length; i++) {
                                  var currentAmount =
                                      spentexpenses[i]['spentamount']!.text;
                                  if (!currentAmount.contains('.')) {
                                    spentexpenses[i]['spentamount']!.text =
                                    '$currentAmount.00';
                                  }
                                }
                              });
                              _addspentcategoryField();
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                List<String?> errorMessages = List.filled(
                                    spentexpenses.length,
                                    ''); // List to store error messages for each row
                                bool isValid =
                                true; // Flag to track overall form validity
                                for (var i = 0; i < spentexpenses.length; i++) {
                                  if (spentexpenses[i]['spentcategory']!
                                      .text
                                      .isEmpty) {
                                    errorMessages[i] = "* Enter a Category Name";
                                    isValid =
                                    false; // Set flag to false if any row has an error
                                  } else if (spentexpenses[i]['spentamount']!
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
                                        title: Text('Submit Confirmation'),
                                        content: Text(
                                            'Are you sure you want to submit?'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _saveDataToSharedPreferences(
                                                  remainingBudgetString,
                                                  debitBudgetString);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SpentDetails(
                                                        tripId: widget.tripid,
                                                        budget: widget.budget,
                                                        tripid: widget.tripid,
                                                        expenses: widget.expenses,
                                                        expenses2: widget.expenses2,
                                                        receivedamnt:
                                                        widget.receivedamnt,
                                                        members: widget.members,
                                                      ),
                                                ),
                                              );
                                              setState(() {});
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
                                } else {
                                  // Set error messages for each row
                                  StringBuffer errorMessageBuffer =
                                  StringBuffer(); // Use StringBuffer to concatenate error messages
                                  for (var i = 0; i < spentexpenses.length; i++) {
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

                /// Dropdown and amount
                //for (var expense in widget.expenses)
                Container(
                  child: Padding(
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
                                        'Category: ${trips[i]['expenses'][j]['spentcategory']}',
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
                                        'Amount  : ₹ ${trips[i]['expenses'][j]['spentamount']}',
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
                ),

                /// category and amount nd remarks
              ],
            ),
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

class Trip {
  final String id;
  final String budget;
  final List<Map<String, String>> expenses2; // Add this line

  Trip({
    required this.id,
    required this.budget,
    required this.expenses2, // Add this line
  });
}

class SalesData {
  final String category;
  final double amount;

  SalesData(this.category, this.amount);
}
