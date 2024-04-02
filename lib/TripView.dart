// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive/hive.dart';
//
// class ViewDataPage extends StatefulWidget {
//   @override
//   _ViewDataPageState createState() => _ViewDataPageState();
// }
//
// class _ViewDataPageState extends State<ViewDataPage> {
//   List<Map<String, dynamic>> trips = [];
//
//   @override
//   void initState() {
//     super.initState();
//     //_loadDataFromHive();
//     _loadDataFromSharedPreferences();
//   }
//
//   void _loadDataFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Retrieve all trip identifiers
//     List<String> tripIds = prefs.getStringList('reportIds') ?? [];
//
//     // Create a temporary list to store the trips
//     List<Map<String, dynamic>> tempTrips = [];
//
//     // Load data for each trip
//     for (String tripId in tripIds) {
//       String tripNameKey = '$tripId:tripName';
//       String sourceKey = '$tripId:source';
//       String fromDateKey = '$tripId:fromDate';
//       String toDateKey = '$tripId:toDate';
//       String totalBudgetKey = '$tripId:totalBudget';
//       String noOfPersonKey = '$tripId:noOfPerson';
//       String personKey = '$tripId:persons';
//       String expensesKey = '$tripId:expenses';
//
//       // Retrieve data using the consistent key pattern
//       String tripName = prefs.getString(tripNameKey) ?? '';
//       String source = prefs.getString(sourceKey) ?? '';
//       String fromDate = prefs.getString(fromDateKey) ?? '';
//       String toDate = prefs.getString(toDateKey) ?? '';
//       String noOfPerson = prefs.getString(noOfPersonKey) ?? '';
//       double totalBudget = prefs.getDouble(totalBudgetKey) ?? 0.0;
//
//       // Retrieve expenses list as List<String>
//       List<String>? expensesListPerson = prefs.getStringList(personKey);
//       List<String>? expensesList = prefs.getStringList(expensesKey);
//
//       // Convert String list to List<Map<String, String>>
//       List<Map<String, String>> expenses2 = [];
//       if (expensesListPerson != null) {
//         expenses2 = expensesListPerson.map((expense2) {
//           List<String> parts = expense2.split(':');
//           return {
//             'name': parts[0],
//             'perAmount': parts[1],
//           };
//         }).toList();
//       }
//
//       List<Map<String, String>> expenses = [];
//       if (expensesList != null) {
//         expenses = expensesList.map((expense) {
//           List<String> parts = expense.split(':');
//           return {
//             'category': parts[0],
//             'amount': parts[1],
//           };
//         }).toList();
//       }
//
//       // Add the trip data to the temporary list
//       tempTrips.add({
//         'tripName': tripName,
//         'source': source,
//         'fromDate': fromDate,
//         'toDate': toDate,
//         'totalBudget': totalBudget.toString(),
//         'noOfPerson': noOfPerson,
//         'persons': expenses2,
//         'expenses': expenses,
//       });
//
//       // Display the data or store it in a list for future use
//       print('Trip ID: $tripId');
//       print('Trip Name: $tripName');
//       print('Source: $source');
//       print('From Date: $fromDate');
//       print('To Date: $toDate');
//       print('Total Budget: $totalBudget');
//       print('Expenses: $expenses');
//       print('-------------');
//     }
//     setState(() {
//       trips = tempTrips;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Saved Data'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             for (var trip in trips)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Trip Name: ${trip['tripName']}'),
//                   Text('Source: ${trip['source']}'),
//                   Text('From Date: ${trip['fromDate']}'),
//                   Text('To Date: ${trip['toDate']}'),
//                   Text('No of persons: ${trip['noOfPerson']}'),
//                   Text('Total Budget: ${trip['totalBudget']}'),
//                   const Divider(),
//                   const Text('Persons:'),
//                   for (var expense2 in trip['persons'] as List<Map<String, String>>)
//                     Row(
//                       children: [
//                         Text('Name: ${expense2['name']}'),
//                         Text('   Amount: ${expense2['perAmount']}'),
//                       ],
//                     ),
//                   const Divider(),
//                   Text('Expenses:'),
//                   for (var expense in trip['expenses'] as List<Map<String, String>>)
//                     Row(
//                       children: [
//                         Text('Category: ${expense['category']}'),
//                         Text('   Amount: ${expense['amount']}'),
//                       ],
//                     ),
//                   const Divider(),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mybudget/spent.dart';
import 'package:mybudget/tripReport.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'Trip.dart';
import 'TripEdit.dart';
import 'dashboard.dart';
import 'duplicate.dart';
import 'package:http/http.dart' as http;


class ViewDataPage extends StatefulWidget {

  const ViewDataPage({super.key});

  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}


class _ViewDataPageState extends State<ViewDataPage> {
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> tripData = []; // Change the type to a list of maps
  Map<String, dynamic> trip = {};

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/tripdashboard.php'));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      List<Map<String, dynamic>> parsedData = [];
      // Ensure that each item in the responseData list is of type Map<String, dynamic>
      responseData.forEach((dynamic item) {
        if (item is Map<String, dynamic>) {
          parsedData.add(item);
        }
      });
      setState(() {
        tripData = parsedData;
      });
    } else {
      print('Failed to load data');
    }
  }




  @override
  void initState() {
    super.initState();
    // fetchTCreation();
    //_loadDataFromSharedPreferences();
    fetchData();
  }

  /*void _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tripIds = prefs.getStringList('reportIds') ?? [];
    List<Map<String, dynamic>> tempTrips = [];

    for (String tripId in tripIds) {
      String tripNameKey = '$tripId:tripName';
      String sourceKey = '$tripId:source';
      String fromDateKey = '$tripId:fromDate';
      String toDateKey = '$tripId:toDate';
      String totalBudgetKey = '$tripId:totalBudget';
      String noOfPersonKey = '$tripId:noOfPerson';
      String personKey = '$tripId:persons';
      String expensesKey = '$tripId:expenses';
      String totalAmountPersonKey = '$tripId:totalAmountPerson';

      String tripName = prefs.getString(tripNameKey) ?? '';
      String source = prefs.getString(sourceKey) ?? '';
      String fromDate = prefs.getString(fromDateKey) ?? '';
      String toDate = prefs.getString(toDateKey) ?? '';
      String noOfPerson = prefs.getString(noOfPersonKey) ?? '';
      String totalBudget = prefs.getString(totalBudgetKey) ?? '';
      String totalAmountPerson = prefs.getString(totalAmountPersonKey) ?? '';


      List<String>? expensesListPerson = prefs.getStringList(personKey);
      List<String>? expensesList = prefs.getStringList(expensesKey);

      List<Map<String, String>> expenses2 = [];
      if (expensesListPerson != null) {
        expenses2 = expensesListPerson.map((expense2) {
          List<String> parts = expense2.split(':');
          return {
            'name': parts[0],
            'perAmount': parts[1],
          };
        }).toList();
      }
      List<Map<String, String>> expenses = [];
      if (expensesList != null) {
        expenses = expensesList.map((expense) {
          List<String> parts = expense.split(':');
          return {
            'category': parts[0],
            'amount': parts[1],
          };
        }).toList();
      }

      tempTrips.add({
        'tripId': tripId, // Include tripId
        'tripName': tripName,
        'source': source,
        'fromDate': fromDate,
        'toDate': toDate,
        'totalBudget': totalBudget.toString(),
        'totalAmountPerson': totalAmountPerson.toString(),
        'noOfPerson': noOfPerson,
        'persons': expenses2,
        'expenses': expenses,
      });
    }
    setState(() {
      trips = tempTrips;
    });
  }*/


  bool isContainerExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),

        child:AppBar(
          title:  Text("Trip",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  const DashBoard()));
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
          backgroundColor:  Color(0xFF8155BA),

        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [

                Visibility(
                  visible: trips.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(10),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Your Trips',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                for (var trip in tripData) buildTripContainer(context, trip),
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
  Widget buildTripContainer(BuildContext context, Map<String, dynamic> trip) {
    return GestureDetector (
      onTap: () {
        print("budget: ${trip['budget'].toString()}");
        print("budget: ${trip['id'].toString()}");
        print("budget: ${trip['member']}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripBudgetReportPage(

              tripname: trip['trip_name'].toString(),
              tripid: trip['trip_id'].toString(),
              id: '7',
              // members: trip['members'].toString(),
              // receivedamnt:trip['received_amount'].toString(),
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
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Place        : ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip['location']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Members : ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip['members']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget   : ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip['budget']}',
                              //text: '${trip.budget}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Received: ₹',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: '${trip['received_amount']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,)
            ],
          ),

        ),
      ),
    );
  }
}


class Trip {
  final String name;
  final String id;
  final String date;
  final String budget;
  final String totalAmountPerson;
  final String members;
  final List<Map<String, String>> expenses;
  Trip({
    required this.name,
    required this.id,
    required this.date,
    required this.budget,
    required this.totalAmountPerson,
    required this.members,
    required this.expenses,
  });
}

