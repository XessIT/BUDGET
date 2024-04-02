import 'dart:convert';
import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mybudget/tripdashboard.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';

//import 'addMemberamount.dart';

class SpentDetails extends StatefulWidget {
  final String members;
  final String budget;
  final String tripid;
  final String tripname;
  final String receivedamnt;

  SpentDetails({super.key,
    required this.budget,
    required this.tripid,
    required this.members,
    required this.tripname,
    required this.receivedamnt,
  });

  @override
  State<SpentDetails> createState() => _SpentDetailsState();
}

class _SpentDetailsState extends State<SpentDetails> {
  List<Map<String, dynamic>> trips = [];
  List<Map<String, TextEditingController>> spentexpenses = [];
  TextEditingController _amountController = TextEditingController();
  TextEditingController editremark = TextEditingController();
  List<Map<String, String>> submittedItems = []; // List to hold submitted items
  double totalBudget = 0.0; // Track whether the user is adding a spentcategory
  bool istextfield = false;
  List<String> notesList = [];
  String? errormsg = '';
  String _selectedExpenseIndex = '-1';
  bool _isVisible = false;
  String? _selectedId;
  String? _selectedCategory;
  TextEditingController editdate = TextEditingController();

  final TextEditingController monthlyincome = TextEditingController();

  //save spent
  Map<String, dynamic> trip = {};
  List<Map<String, dynamic>> tripData = [];
  List<dynamic> _tripExpenses = [];
  List<Map<String, dynamic>> _categories = [
    {'name': 'Bus Fair', 'icon': Icons.directions_bus},
    {'name': 'Clothing', 'icon': Icons.shopping_bag},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Entertainment', 'icon': Icons.local_movies},
    {'name': 'Fuel', 'icon': Icons.local_gas_station},
    {'name': 'Gifts', 'icon': Icons.card_giftcard},
    {'name': 'Groceries', 'icon': Icons.shopping_cart},
    {'name': 'Health', 'icon': Icons.local_hospital},
    {'name': 'Restaurant', 'icon': Icons.restaurant},
    {'name': 'Snacks', 'icon': Icons.fastfood},
    {'name': 'Tea', 'icon': Icons.local_drink},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Utilities', 'icon': Icons.settings},
    {'name': 'Other', 'icon': Icons.category},
  ];

  String url = 'http://localhost/BUDGET/lib/BUDGETAPI/trip_spent.php';
  Future<void> readRecords(String trip_id) async {
    var url =
        'http://localhost/BUDGET/lib/BUDGETAPI/trip_spent.php'; // Replace with your actual URL
    var modifiedUrl =
    Uri.parse(url).replace(queryParameters: {'trip_id': trip_id});

    var response = await http.get(modifiedUrl);

    if (response.statusCode == 200) {
      setState(() {
        _tripExpenses = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  List<Map<String,dynamic>> spentData=[];

  Future<void> fetchTSpent() async {
    try {
      print("trip Id:${widget.tripid}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_spent&trip_id=${widget.tripid}');
      final response = await http.get(url);
      print("id members URL :$url" );
      print("M response.statusCode :${response.statusCode}" );
      print("M response .body :${response.body}" );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          setState(() {
            spentData = responseData.cast<Map<String, dynamic>>();
            print("spentdata:$spentData");
          });
        } else {
          print('Invalid response data format');
        }
      } else {
        // Handle non-200 status code
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  void savespentdata(List<dynamic> spentexpenses, String tripid) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/trip_spent.php');
    // Extract data from TextEditingController objects and create a new list of Map
    List<Map<String, dynamic>> expenseDataList = [];

    for (var expense in spentexpenses) {
      Map<String, dynamic> expenseData = {
        'date': expense['date'].text,
        'category': expense['spentcategory'].text,
        'amount': expense['spentamount'].text,
        'remark': expense['remarks'].text,
      };
      expenseDataList.add(expenseData);
    }
    // Make POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tripspent': expenseDataList,
        'uid': "7",
        'trip_id': tripid,
      }),
    );

    // Check if request was successful
    if (response.statusCode == 200) {
      print("Response Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print('Data sent successfully!');
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
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
  TextEditingController categoryEdit = TextEditingController();
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


  List<Map<String, TextEditingController>> expenses2 = [];


  ///delele and update
  Future<void> delete(String id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/trip_spent.php?id=$id');
      final response = await http.delete(url);
      print("Delete Url: $url");
      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SpentDetails(
          budget: widget.budget,
          tripname: widget.tripname,
          tripid: widget.tripid,
          members: widget.members,
          receivedamnt: widget.members,
        )));
      }
      else {
        // Error handling, e.g., show an error message
        print('Error: ${response.statusCode}');
      }
    }
    catch (e) {
      // Handle network or server errors
      print('Error making HTTP request: $e');
    }
  }

  Future<void> editExpense(int id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/trip_spent.php');
      print("Update url: $url");
      final response = await http.put(
        url,
        body: jsonEncode({
          "date": editdate.text,
          "categories": categoryEdit.text,
          "amount": _amountController.text,
          "remark": editremark.text,
          "id": id,
        }),
      );
      print("U Response Status: ${response.statusCode}");
      print("U Response Body: ${response.body}");
      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMemberApproval()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Edited")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Edit")));
      }
    } catch (e) {
      print("Error during signup: $e");
      // Handle error as needed
    }
  }

  String totalSpent = ''; // State variable to hold the total spent amount
  String remaining = '';
  void fetchTotalSpent(String trip_id) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/spentcalculation.php?trip_id=$trip_id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double monthlyIncomeAmount = double.parse(widget.receivedamnt);
      double totalSpentAmount = double.parse(data['totalSpent']);
      double remainingAmount = monthlyIncomeAmount - totalSpentAmount;
      //  Provider.of<RemainingAmountProvider>(context, listen: false).updateRemaining(remainingAmount.toStringAsFixed(2));
      setState(() {
        totalSpent = totalSpentAmount.toStringAsFixed(2);
        remaining = remainingAmount.toStringAsFixed(2);
      });
    } else {
      print('Failed to fetch total spent. Error: ${response.statusCode}');
    }
  }

  int index = 0;
  @override
  void initState() {
    super.initState();
    fetchTSpent();
    fetchTotalSpent(widget.tripid);
    // readRecords(widget.tripid);
    print(widget.members);
    _addspentcategoryField();
    updatetotalspent();
    _updateTotalBudget();
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

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  @override
  Widget build(BuildContext context) {

    double totalBudgetAmount = _calculateTotalBudget(trips);
    double remainingOrDebit = (double.tryParse(monthlyincome.text.toString()) ?? 0.0) - totalBudgetAmount;
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
            child: GestureDetector(
              onTap: () {
                /*Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddMemberAmount(
                        tripid:widget.tripid
                    )));*/
              },
              child: Icon(Icons.terrain_rounded, color: Colors.white),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TripDashboard(
                )));
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                                    Text('Spent',style: Theme.of(context).textTheme.labelMedium),
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
                                backgroundColor: totalBudgetAmount > double.parse(widget.receivedamnt)
                                    ? Colors.red // Orange color when spent exceeds received amount
                                    : Colors.teal,
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Spent', style: Theme.of(context).textTheme.labelMedium),
                                    SizedBox(width: 70),
                                    Text('₹${totalSpent.isNotEmpty ? totalSpent : '0.00'}', style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                SizedBox(height: 2), // Add space between the row and the text widgets
                                Container(
                                  width: 200, // Set the desired width
                                  child: LinearProgressIndicator(
                                    value: double.tryParse(widget.receivedamnt) != null && double.parse(widget.receivedamnt) != 0
                                        ? totalSpent.isNotEmpty
                                        ? double.parse(totalSpent) / double.parse(widget.receivedamnt) // Calculate progress ratio if totalSpent is not empty
                                        : 0.0 // Default value if totalSpent is empty
                                        : 0.0, // Default value if received amount is not a valid number or is zero
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      totalSpent.isNotEmpty && double.parse(totalSpent) > double.parse(widget.receivedamnt)
                                          ? Colors.red // Red color for spent exceeding income
                                          : Colors.teal, // Teal color for remaining budget or default color if totalSpent is empty
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        /// Spent

                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                child: Icon(SimpleIcons.affine, color: Colors.white),
                                backgroundColor: totalBudgetAmount > double.parse(widget.receivedamnt)
                                    ? Colors.red // Orange color when spent exceeds received amount
                                    : Colors.teal,
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      remaining.isNotEmpty && double.parse(remaining) >= 0 ? 'Remaining' : 'Debit',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    SizedBox(width: 70),
                                    Text(
                                      '₹${remaining.isNotEmpty ? (double.parse(remaining) >= 0 ? remaining : (double.parse(remaining) * -1).toString()) : '0.00'}',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2), // Add space between the row and the text widgets
                                Container(
                                  width: 200, // Set the desired width
                                  child: LinearProgressIndicator(
                                    value: double.tryParse(widget.receivedamnt) != null && double.parse(widget.receivedamnt) != 0
                                        ? remaining.isNotEmpty
                                        ? double.parse(remaining).abs() / double.parse(widget.receivedamnt) // Calculate progress ratio if remaining is not empty
                                        : 0.0 // Default value if remaining is empty
                                        : 0.0, // Default value if received amount is not a valid number or is zero
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      remaining.isNotEmpty && double.parse(remaining) < 0
                                          ? Colors.red // Red color for debit
                                          : Colors.teal, // Teal color for remaining budget or default color if remaining is empty
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        /// Remaining

                        // Add other rows with CircleAvatar and LinearProgressIndicator here
                      ],
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                                                prefixText: "₹",
                                                hintText: spentexpenses[i]
                                                ['spentamount']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Rs'
                                                    : null,
                                                hintStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(6),
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                              ],
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
                                              savespentdata(spentexpenses,widget.tripid);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SpentDetails(
                                                        tripid:widget.tripid,
                                                        // tripId: widget.tripid,
                                                        budget: widget.budget,
                                                        // tripid: widget.tripid,
                                                        receivedamnt: widget.receivedamnt,
                                                        members: widget.members,
                                                        tripname: widget.tripname,
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


                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              children: _buildExpenseList(),
                            ),
                            SizedBox(
                              height: 80,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16, // Adjust bottom margin as needed
                        right: 16, // Adjust right margin as needed
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF8155BA),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(
                                  0,
                                  2,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Dropdown and amount
                //for (var expense in widget.expenses)

                /// category and amount nd remarks
              ],
            ),
          ),

        ),


      ),
    );

  }


  List<Widget> _buildExpenseList() {
    Map<String, dynamic> groupedExpenses = {};

    for (var expense in spentData) {
      String date = expense['date']!;
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add({...expense, 'show': false});
    }

    List<Widget> expenseWidgets = [];

    groupedExpenses.forEach((date, expenses) {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      // String dayName = DateFormat('EEEE').format(parsedDate);

      List<Widget> expensesList = [];
      for (var expense in expenses) {
        expensesList.add(
          GestureDetector
            (
            onTap: () {
              var id = expense['id'];
              setState(() {
                _selectedExpenseIndex = id;
              });
            },
            child: Padding(
              padding:
              const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ' ${expense['categories']}',
                                      style:
                                      Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${double.parse(expense['amount']!).toStringAsFixed(2)}',
                                      style:
                                      Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Visibility(
                                  visible: expense['remark'] != null &&
                                      expense['remark']!.isNotEmpty,
                                  child: Text(
                                    "Remarks: ${expense['remark'] ?? ''}",
                                    style:
                                    Theme.of(context).textTheme.bodySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_selectedExpenseIndex == expense['id'])
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Color(0xFF8155BA),
                            ),
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (ctx) =>
                                  // Dialog box for register meeting and add guest
                                  AlertDialog(
                                    backgroundColor: Colors.grey[800],
                                    title: const Text('Delete',
                                        style: TextStyle(color: Colors.white)),
                                    content: const Text("Do you want to Delete the Spent?",
                                        style: TextStyle(color: Colors.white)),
                                    actions: [
                                      TextButton(
                                          onPressed: () async{
                                            delete(expense['id']);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                content: Text("You have Successfully Deleted")));
                                          },
                                          child: const Text('Yes')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No'))
                                    ],
                                  )
                              );
                            },
                          ),
                        if (_selectedExpenseIndex == expense['id'])
                          IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFF8155BA)),
                            onPressed: () async {
                              _selectedId = expense['id'];
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Expense'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        style: Theme.of(context).textTheme.labelMedium,
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2300),
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  colorScheme: ColorScheme.light(
                                                    primary: Color(0xFF8155BA),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (pickDate == null) return;
                                          {
                                            setState(() {
                                              editdate.text =
                                                  DateFormat('dd-MM-yyyy').format(pickDate);
                                              errormsg = null;
                                            });
                                          }
                                        },
                                        controller: editdate=TextEditingController(text: expense["date"]),
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(
                                            Icons.date_range,
                                            size: 14,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Date",
                                          labelStyle: Theme.of(context).textTheme.labelMedium,
                                        ),
                                      ),
                                      TypeAheadFormField(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: categoryEdit=TextEditingController(text: expense["categories"]),
                                          decoration: InputDecoration(
                                            labelText: 'Category',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.black),
                                          ),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          return _categories.where((category) =>
                                              category['name'].toLowerCase().contains(pattern.toLowerCase()));
                                        },
                                        itemBuilder: (context, suggestion) {
                                          return ListTile(
                                            leading: Icon(
                                              suggestion['icon'],
                                              color: Color(0xFF8155BA),
                                            ),
                                            title: Text(
                                              suggestion['name'],
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        },
                                        onSuggestionSelected: (suggestion) {
                                          setState(() {
                                            categoryEdit.text = suggestion['name'];
                                          });
                                        },
                                      ),
                                      TextField(
                                        controller: _amountController=TextEditingController(text: expense['amount']),
                                        decoration: InputDecoration(
                                            labelText: 'Amount'),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: editremark=TextEditingController(text: expense['remark']),
                                        decoration: InputDecoration(
                                            labelText: 'Remarks'),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        editExpense(int.parse(expense['id'].toString()));
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SpentDetails(
                                          tripid:widget.tripid,
                                          budget: widget.budget,
                                          receivedamnt: widget.receivedamnt,
                                          members: widget.members,
                                          tripname: widget.tripname,
                                        )));
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }

      expenseWidgets.add(
        Padding(
          padding:
          const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /*  Text(
                '$dayName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),*/
              Text(
                '$date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
      );

      expenseWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: expensesList,
            ),
          ),
        ),
      );
    });

    return expenseWidgets;
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
  Future<void> updateRecord(NavigatorState nav) async {
    var headers = {'Content-Type': 'application/json'};

    var response = await http.put(Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'id': _selectedId,
          'category': _selectedCategory,
          'amount': _amountController.text
        }));

    if (response.statusCode == 200) {
      nav.pop();
      readRecords(widget.tripid);
    } else {
      print('Failed to update record: ${response.body}');
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
