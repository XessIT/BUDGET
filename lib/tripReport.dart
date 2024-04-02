import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/DashBoard.dart';
import 'package:mybudget/reports.dart';
import 'package:glass_kit/glass_kit.dart';
import 'TripView.dart';

class TripBudgetReportPage extends StatefulWidget {
  final String tripid;
  final String tripname;
  final String id;
  const TripBudgetReportPage({super.key, required this.tripid, required this.tripname, required this.id});

  @override
  _TripBudgetReportPageState createState() => _TripBudgetReportPageState();
}

class _TripBudgetReportPageState extends State<TripBudgetReportPage> {
  List<String> reportIds = [];
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> tripData = []; // Change the type to a list of maps
  Map<String, dynamic> trip = {};
  List<Map> combineData = [];
  String getValue ="";
  Future<void> fetchTCombine() async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=combine_table&uid=${widget.id}&trip_id=${widget.tripid}');
      final response = await http.get(url);
      print("id fetch URL: $url");

      if (response.statusCode == 200) {
        print("response.statusCode: ${response.statusCode}");
        print("response.body: ${response.body}");

        // Check if the response is JSON
        if (response.headers['content-type'] == 'application/json') {
          final responseData = json.decode(response.body);

          if (responseData is List<dynamic>) {
            setState(() {

              getValue=responseData[0]["trip_type"];


              // print("compine table:$");
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid response data format"),
              ),
            );
            print('Invalid response data format');
          }
        } else {
          // Handle non-JSON response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unexpected response format"),
            ),
          );
          print('Unexpected response format');
        }
      } else {
        // Handle non-200 status code
        print('Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.statusCode}"),
          ),
        );
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
        ),
      );
    }
  }


  String tripType ="";
  String tripName ="";
  String source ="";
  String fromDate ="";
  String toDate ="";
  double totalBudget =0.0;
  String noOfPersonController ="";
  List<double> balanceAMt =[];


  List<Map<String,dynamic>>creationData =[];
  Future<void> fetchTCreation() async {
    try {
      print("trip Id:${widget.tripid}");
      print("Id:${widget.id}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_creation&uid=${widget.id}&trip_id=${widget.tripid}');
      final response = await http.get(url);
      print("id fetch Creation URL :$url" );
      print("C response.statusCode :${response.statusCode}" );
      print("C response .body :${response.body}" );
      if (response.statusCode == 200) {
        print("response.statusCode :${response.statusCode}" );
        print("response .body :${response.body}" );
        final responseData = json.decode(response.body);
        final parsedNoOfPersonController = int.tryParse(noOfPersonController.toString());



        if (responseData is List<dynamic>) {
          setState(() {
            creationData = responseData.cast<Map<String, dynamic>>();
            if (creationData.isNotEmpty) {
              setState(() {
                tripType = creationData[0]["trip_type"];
                tripName = creationData[0]["trip_name"];
                source = creationData[0]["location"];
                fromDate = creationData[0]["from_date"];
                toDate = creationData[0]["to_date"];
                totalBudget= double.tryParse(creationData[0]["budget"])??0.0;
                noOfPersonController = creationData[0]["members"];

                print("Trip_creation data--$creationData" );

              });
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("This mobile number is not member. Enter the member mobile number."),
            ),
          );
          //    referreridcotroller.clear();
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
  List<Map<String,dynamic>>membersData=[];
  double values =0.0;
  String? returnvalue ="Return";
  String? balancevalue ="Balance";
  Future<void> fetchTMembers() async {
    try {
      print("trip Id:${widget.tripid}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_members&trip_id=${widget.tripid}');
      final response = await http.get(url);
      print("id members URL :$url");
      print("M response.statusCode :${response.statusCode}");
      print("M response .body :${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        double totalAmounts = 0.0; // Initialize total amount
        for (var i = 0; i < responseData.length; i++) {
          double amount = double.tryParse('${responseData[i]["amount"]}') ?? 0;
          totalAmounts += amount;

        }

        if (responseData is List<dynamic>) {
          setState(() {
            membersData = responseData.cast<Map<String, dynamic>>();
            creationtotal = totalAmounts;




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
  List<Map<String,dynamic>>spentData=[];
  Future<void> fetchTSpent() async {
    try {
      print("trip Id:${widget.tripid}");
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php?table=trip_spent&trip_id=${widget.tripid}');
      final response = await http.get(url);
      print("id spent URL :$url");
      print("S response.statusCode :${response.statusCode}");
      print("S response .body :${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        double spentAmounts = 0.0; // Initialize total amount
        for (var i = 0; i < responseData.length; i++) {
          double amount = double.tryParse('${responseData[i]["amount"]}') ?? 0;
          spentAmounts += amount;
        }
        if (responseData is List<dynamic>) {
          setState(() {
            spentData = responseData.cast<Map<String, dynamic>>();
            print("spent data$spentData");
            if(spentData.isNotEmpty){
              spenttotal =spentAmounts;}
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
  /* double totalAmountPerson = 0.0;
  double receivedAmt = 0.0;
  double valueget3=0.0;*/
/*
  double getReceivedAmt() {
    double valueget = 0.0;
    for (var mData in membersData) {
      double amount = double.tryParse(mData['amount']) ?? 0.0;
      valueget += amount;
      setState(() {
        receivedAmt =valueget;
        print("MData $receivedAmt??--00");
      });
    }
    return receivedAmt;
  }
*/


  List<Map<String, dynamic>> combinedData = [];

  Future<void> fetchData() async {
    try {
      await fetchTCreation();
      await fetchTMembers();
      await fetchTSpent();

      // Combine the data
      setState(() {
        combinedData.clear();
        combinedData.addAll(creationData);
        combinedData.addAll(membersData);
        combinedData.addAll(spentData);
      });

      print("Combined Data: $combinedData");
    } catch (error) {
      print('Error fetching data: $error');
    }
  }
  int index = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTMembers();
    fetchTCreation();
    fetchTSpent();
   // _loadReportIds();
  }

  /*Future<void> _loadReportIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reportIds = prefs.getStringList('reportIds') ?? [];
    });
  }*/
  double creationtotal = 0.0;
  double spenttotal = 0.0;
  double valueget2 = 0.0;
  double spendPerHead =0.0;
  double remainingAmount =0.0;
  @override
  Widget build(BuildContext context) {
    spentData.sort((a, b) => DateTime.parse(a["date"]).compareTo(DateTime.parse(b["date"])));
    spendPerHead = spenttotal /int.parse(noOfPersonController);
    remainingAmount = creationtotal - spenttotal;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Trip Budget Reports",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Reports(uid: '',)));
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
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(combinedData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      elevation: 10,
                      shadowColor: Colors.deepPurple,
                      // color: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("Info",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Location"),
                                Text("${combinedData[0]["location"]}"),

                              ],
                            ), Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("From Date"),
                                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(combinedData[0]["from_date"]))),
                              ],
                            ), Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("To Date"),
                                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(combinedData[0]["to_date"]))),
                              ],
                            ), /*Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("No of Members"),
                            Text("${combinedData[0]["members"]}"),

                          ],
                        ),*/
                            Divider(),
                            Row(
                              children: [
                                Text("Amount Details",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("No of Members"),
                                Text("${creationData[0]["members"]}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Spend Per Head"),
                                Text("₹${spendPerHead.toStringAsFixed(2)}"),
                              ],
                            ),
                            SizedBox(height: 10,),
                            for(int i=0 ;i<creationData.length;i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Budget"),
                                  Text("₹${totalBudget.toStringAsFixed(2)}"),
                                ],
                              ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Received Amount"),
                                Text("₹${creationtotal.toStringAsFixed(2)}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Spent Amount"),
                                Text("₹${spenttotal.toStringAsFixed(2)}"),
                              ],
                            ),


                            ///Divider code for calculation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Remaining Amount"),
                                Text("₹${remainingAmount.toStringAsFixed(2)}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),

                            Divider(),
                            Row(
                              children: [
                                Text("Received Amount",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            for(int i=0 ;i<membersData.length;i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${membersData[i]["member_name"]}"),
                                  Text("₹${double.tryParse(membersData[i]["amount"])!.toStringAsFixed(2)}"),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Divider(),
                                Text("₹${double.tryParse(creationtotal.toString())!.toStringAsFixed(2)}"),

                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),



                            Divider(),
                            Row(
                              children: [
                                Text("Spent Exepences by Categories",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),

                            for(int i=0 ;i<spentData.length;i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('dd-MMM').format(DateTime.parse(spentData[i]["date"]))),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Text("${spentData[i]["categories"]}"),
                                      if (spentData[i]["remark"] != null &&
                                          spentData[i]["remark"].isNotEmpty)
                                        Container(child: Text("(${spentData[i]["remark"]})")),
                                    ],
                                  ),
                                  Text("₹${double.tryParse(spentData[i]["amount"])!.toStringAsFixed(2)}"),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("₹${spenttotal.toStringAsFixed(2)}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(width:80,child: Divider()),
                              ],
                            ),
                            Divider(),

                            /*Row(
                          children: [
                            Text("Remarks",style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                        for(int i=0 ;i<spentData.length;i++)
                          Row(
                            children: [
                              if (spentData[i]["remark"] != null &&
                                  spentData[i]["remark"].isNotEmpty)
                              Text("${spentData[i]["remark"]}"),

                            ],
                          ),
                        Divider(),*/
                            // Row(
                            //   children: [
                            //     Text("Amount Details",style: TextStyle(fontWeight: FontWeight.bold),),
                            //   ],
                            // ),
                            // for(int i=0 ;i<creationData.length;i++)
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Budget"),
                            //     Text("${creationData[0]["budget"]}"),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Received Amount"),
                            //     Text("$creationtotal"),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Spent Amount"),
                            //     Text("$spenttotal"),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Spent Per Head"),
                            //     Text(spendPerHead.toStringAsFixed(2)),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("No of Persons"),
                            //     Text("${creationData[0]["members"]}"),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Remaining Amount"),
                            //     Text(remainingAmount.toStringAsFixed(2)),
                            //   ],
                            // ),
                            // Divider(),
                            Row(
                              children: [
                                Text("Transaction Details",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Table(
                                      border: TableBorder.all(),
                                      defaultColumnWidth:const FixedColumnWidth(100.0),
                                      columnWidths: const <int, TableColumnWidth>{
                                        0:FixedColumnWidth(50),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      // s.no
                                      children: [const TableRow(children:[
                                        TableCell(child:Center(child: Text('S.No.',style: TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold)),)),
                                        TableCell(child:Center(child: Text('Name',style: TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold)),)),
                                        TableCell(child:Center(child: Text('Amount \nto be \npaid',style: TextStyle(fontSize: 15, color: Colors.red,fontWeight: FontWeight.bold)),)),
                                        TableCell(child:Center(child: Text('Amount \n to be \nReceived',style: TextStyle(fontSize: 15, color: Colors.green,fontWeight: FontWeight.bold)),)),
                                      ]),
                                        if(membersData.isNotEmpty)
                                          for(var i = 0 ;i < membersData.length; i++) ...[
                                            TableRow(
                                              // decoration: BoxDecoration(color: Colors.grey[200]),
                                                children:[
                                                  //2 name
                                                  TableCell(child: Center(child: Text("${i+1}"))),
                                                  TableCell(child: Text(" ${membersData[i]["member_name"]}")),
                                                  TableCell(
                                                    child: Center(
                                                      child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("${spendPerHead > double.tryParse(membersData[i]["amount"])! ? spendPerHead - double.tryParse(membersData[i]["amount"])! : 0}",
                                                              style: TextStyle(color: Colors.red),
                                                            ),

                                                          ]),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Center(
                                                      child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("${double.tryParse(membersData[i]["amount"])! > spendPerHead ? double.tryParse(membersData[i]["amount"])! - spendPerHead : 0}",
                                                              style: TextStyle(color: Colors.green),
                                                            ),                                                       ]),
                                                    ),
                                                  )
                                                ]),
                                          ]
                                      ]),
                                )
                            ),








                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        )
    );
  }

  /*Future<Map<String, dynamic>> _getReportData(String tripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripName = prefs.getString('$tripId:trip_name');
    String? noOfPerson = prefs.getString('$tripId:members');
    String? source = prefs.getString('$tripId:location');
    String? fromDate = prefs.getString('$tripId:from_date');
    String? toDate = prefs.getString('$tripId:to_date');
    String? totalBudget = prefs.getString('$tripId:amount');
    String? totalAmountPerson =
        prefs.getString('$tripId:totalAmountPerson') ?? "";
    List<String>? expensesList = prefs.getStringList('$tripId:amount');
    List<String>? expensesListPerson = prefs.getStringList('$tripId:members');
    List<String>? spentExpensesList =
    prefs.getStringList('$tripId:spentexpenses');
    double remaining = prefs.getDouble('$tripId:remaining') ?? 0.0;
    double debit = prefs.getDouble('$tripId:debit') ?? 0.0;

    // Prepare the data
    Map<String, dynamic> reportData = {
      'tripName': tripName,
      'noOfPerson': noOfPerson,
      'source': source,
      'fromDate': fromDate,
      'toDate': toDate,
      'totalBudget': totalBudget,
      'totalAmountPerson': totalAmountPerson,
      'expensesList': expensesList,
      'expensesListPerson': expensesListPerson,
      'spentExpenses': spentExpensesList,
      'remaining': remaining,
      'debit': debit
    };

    return reportData;
  }*/

  Widget _buildReportCard(Map<String, dynamic> data, BuildContext context) {
    String totalBudget = data['amount'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDataPage(),
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
                      Text(data['trip_name'] ?? '',
                          style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: 10),
                      Text(
                          'Total Budget : ₹${double.parse(totalBudget).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _calculateBalance(dynamic amount, double spendPerHead) {
    if (amount == null) return '';

    try {
      double amountValue = double.parse(amount.toString());
      return '${(amountValue - spendPerHead).toStringAsFixed(2)}';
    } catch (e) {
      return '';
    }
  }
  Color _calculateBalanceColor(dynamic amount, double spendPerHead) {
    if (amount == null) return Colors.black;

    try {
      double amountValue = double.parse(amount.toString());
      double balance = amountValue - spendPerHead;
      if (balance > 0) {
        return Colors.green;
      } else if (balance < 0) {
        return Colors.red;
      } else {
        return Colors.black;
      }
    } catch (e) {
      return Colors.black;
    }
  }



}

class DetailedReportPage extends StatelessWidget {
  final Map<String, dynamic> reportData;

  DetailedReportPage({required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reportData['tripName'] ?? '',
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
  int index = 0;

  Widget _buildReportContent(BuildContext context) {
    String? tripName = reportData['tripName'];
    String? source = reportData['source'];
    String? fromDate = reportData['fromDate'];
    String? toDate = reportData['toDate'];
    String? noOfPerson = reportData['noOfPerson'];
    List<String>? expensesList = reportData['expensesList'];
    List<String>? personsList = reportData['expensesListPerson'];
    final List<String>? spentExpensesList = reportData['spentExpenses'];
    String? totalAmountPerson =
    reportData['totalAmountPerson']; // Retrieve totalAmountPerson
    //double remaining = reportData['remaining'] ?? 0.0;
    // double debit = reportData['debit'] ?? 0.0;
    String? totalBudget = reportData['totalBudget'];

    // Calculate total spent amount
    double totalSpentAmount = 0.0;
    if (spentExpensesList != null) {
      for (String expense in spentExpensesList) {
        List<String> parts = expense.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalSpentAmount += amount;
      }
    }

    // Calculate total expenses
    double totalExpenses = 0.0;
    if (expensesList != null) {
      for (String expense in expensesList) {
        List<String> parts = expense.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalExpenses += amount;
      }
    }

    // Calculate total amount per person
    double totalAmountPerPerson = 0.0;
    if (personsList != null) {
      for (String person in personsList) {
        List<String> parts = person.split(':');
        double amount = double.tryParse(parts[1]) ?? 0.0;
        totalAmountPerPerson += amount;
      }
    }

    // Calculate remaining amount
    double remainingAmount =
        double.parse(totalAmountPerson!) - totalSpentAmount;

// Calculate debit amount
    double debitAmount = totalSpentAmount - double.parse(totalAmountPerson!);
    double perPersonSpend = totalSpentAmount / int.parse(noOfPerson!);

    // Calculate balance amount for each member
    List<Map<String, dynamic>> balanceAmounts = [];
    double totalReceivedAmount = double.parse(totalAmountPerson);
    int numberOfMembers = int.parse(noOfPerson);

    // Get the list of members and their received amounts
    List<Map<String, dynamic>> membersData = personsList!.map((person) {
      final parts = person.split(':');
      return {'name': parts[0], 'receivedAmount': double.parse(parts[1])};
    }).toList();

    // Calculate the balance amount for each member
    balanceAmounts = membersData.map((memberData) {
      double receivedAmount = memberData['receivedAmount'];
      double balanceAmount = perPersonSpend - receivedAmount;
      return {
        'name': memberData['name'],
        'receivedAmount': receivedAmount,
        'balanceAmount': balanceAmount,
      };
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Info",
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        _buildInfoSection(context, 'Location', source),
        _buildInfoSection(context, 'From Date', fromDate),
        _buildInfoSection(context, 'To Date', toDate),
        _buildInfoSection(context, 'Number of Members', noOfPerson),
        Divider(),
        //_buildExpensesList(context, expensesList, totalExpenses),
        _buildPersonsList(context, personsList, totalAmountPerson!),
        Divider(),
        _buildTotalSpentExpenses(context, spentExpensesList),
        _buildTotalSpentAmount(context, totalSpentAmount),
        if (spentExpensesList != null &&
            spentExpensesList.isNotEmpty) // Condition for showing remarks
          _buildremarks(context, spentExpensesList),
        Divider(),
        Text(
          'Amount Details',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text('₹${double.parse(totalBudget!).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Received Amount ',
                style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                totalAmountPerson.isNotEmpty
                    ? '₹${double.parse(totalAmountPerson!).toStringAsFixed(2)}'
                    : '₹0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spent Amount ', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '₹${totalSpentAmount!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spent Per Head', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '₹${perPersonSpend.toStringAsFixed(2)}', // Display perPersonSpend
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No Of persons', style: Theme.of(context).textTheme.bodySmall),
            Align(
              alignment: Alignment.topRight,
              child: Text(noOfPerson.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
        ),

        Column(
          children: [
            if (remainingAmount > 0 && debitAmount <= 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Remaining Amount",
                      style: Theme.of(context).textTheme.bodySmall),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("₹${remainingAmount.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            if (debitAmount > 0 && remainingAmount <= 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Debit Amount",
                      style: Theme.of(context).textTheme.bodySmall),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("₹${debitAmount.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
          ],
        ),

        SizedBox(height: 10,),
        Divider(),
        Text(
          'Transaction Details',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
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
                    child: Text('Balance ₹'),
                  ),
                ),

              ],
            ),
            // Generate rows based on balance amounts
            for (var balanceData in balanceAmounts)
            // Inside the TableRow for balance amounts
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${++index}. ${balanceData['name']}'), // Increment index and display in the format "1. Name"
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(balanceData['receivedAmount'].toStringAsFixed(2),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        balanceData['balanceAmount'] < 0
                            ? '${balanceData['balanceAmount'].toStringAsFixed(2)} Return'
                            : '${balanceData['balanceAmount'].toStringAsFixed(2)} Get',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: balanceData['balanceAmount'] < 0 ? Colors.red : Colors.green,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
          ],
        )
        /* SizedBox(
          height: 15,
        ),
        if (debitAmount > 0 && remainingAmount <= 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Each member will pay the amount of Rs \n ₹${(debitAmount / int.parse(noOfPerson!)).toStringAsFixed(2)}/-",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        if (remainingAmount > 0 && debitAmount <= 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Each member will get a refund of Rs \n ₹${(remainingAmount / int.parse(noOfPerson!)).toStringAsFixed(2)}/-",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),*/
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall!),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'N/A',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }


  Widget _buildPersonsList(
      BuildContext context,
      List<String>? personsList,
      String totalAmountPerson,
      ) {
    if (personsList == null || personsList.isEmpty) {
      return SizedBox.shrink();
    }



    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Received Amounts',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: personsList.map((person) {
            final parts = person.split(':');
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  parts[0],
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(width: 8),
                Text(
                  parts[1].isNotEmpty
                      ? '₹${double.parse(parts[1]).toStringAsFixed(2)}'
                      : "0.0",
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
        ),
        SizedBox(height: 8),
        /* Align(
          alignment: Alignment.centerRight,
          child: Text(
            formattedTotalAmount,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),*/
      ],
    );
  }

  Widget _buildTotalSpentAmount(BuildContext context, double totalSpentAmount) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 1,
            width: 70,
            color: Colors.grey, // Small line color
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '₹${totalSpentAmount.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSpentExpenses(
      BuildContext context, List<String>? spentExpensesList) {
    if (spentExpensesList == null || spentExpensesList.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spent Expenses by Categories',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: spentExpensesList.map((expense) {
            final parts = expense.split(':');
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    parts[2],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  flex: 2,
                  child: Text(
                    parts[0],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${double.parse(parts[1]).toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildremarks(BuildContext context, List<String>? spentExpensesList) {
    if (spentExpensesList == null || spentExpensesList.isEmpty) {
      return SizedBox.shrink();
    }

    // Check if there are any remarks present in the list
    bool remarksPresent = spentExpensesList.any((expense) {
      final parts = expense.split(':');
      return parts.length > 3 && parts[3].isNotEmpty;
    });

    if (!remarksPresent) {
      return SizedBox.shrink();
    }

    List<Widget> remarkWidgets = spentExpensesList
        .map((expense) {
      final parts = expense.split(':');
      if (parts.length > 3 && parts[3].isNotEmpty) {
        return Column(
          children: [
            Text(
              parts[3].trim(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    })
        .where((widget) => widget != SizedBox.shrink())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          'Remarks',
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: remarkWidgets,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
